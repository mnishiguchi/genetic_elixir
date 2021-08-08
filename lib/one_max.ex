defmodule OneMax do
  @moduledoc """
  The one-max problem
  - Question: What is the maximum sum of a bitstring of length N?
  - Answer: N
  """

  @bitstring_length 1000
  @chromosome_count 100

  @doc """
  ## Examples

    iex> OneMax.run
    Current Best: 1000

  """
  def run do
    solution = algorithm(initialize_population())
    IO.puts("\nAnswer is")
    IO.inspect(solution)
  end

  @doc """
  ## Parameters
  - population - the current generation's population
  """
  def algorithm(population) do
    best = Enum.max_by(population, &Enum.sum/1)
    IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

    if Enum.sum(best) == @bitstring_length do
      # Base case (termination criteria)
      # - We know the answer is the bitstring length.
      best
    else
      # Recursive case
      population
      |> evaluate_population()
      |> select_parents()
      |> create_children()
      |> mutate_children()
      |> algorithm()
    end
  end

  @doc """
  Creates a list of randomly distributed bitstrings.

  Typically, the more chromosomes you have, the longer it takes to perform transformations on the
  entire population. Conversely, the fewer chromosomes you have, the longer it takes to produce a
  viable solution to our problem and the more susceptible our population is to premature
  convergence.
  """
  def initialize_population do
    for _ <- 1..@chromosome_count do
      for _ <- 1..@bitstring_length do
        Enum.random(0..1)
      end
    end
  end

  @doc """
  Evaluates each chromosome based on a fitness function, and sorts the population based on each
  chromosome's fitness.

  ## Parameters
  - population - the current generation's population
  """
  def evaluate_population(population) do
    # Sort the population by the sum in descending order
    Enum.sort_by(population, &Enum.sum/1, &>=/2)
  end

  @doc """
  Picks the parents that will be combined to create new solutions and formats the chromosomes
  nicely for crossover.

  ## Parameters
  - population - the current generation's population
  """
  def select_parents(population) do
    population
    |> Enum.chunk_every(2)
    # Tuples are easier to work with in the next step.
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Takes two or more parent chromosomes and produces two or more child chromosomes.

  ## Parameters
  - population - the current generation's population
  """
  def create_children(population) do
    Enum.reduce(population, [], fn {parent1, parent2}, acc ->
      # A random crossover point (uniform integer between 0 and N-1)
      cx_point = :rand.uniform(@bitstring_length)

      {h1, t1} = Enum.split(parent1, cx_point)
      {h2, t2} = Enum.split(parent2, cx_point)

      # Single-point crossover is one of the simplest crossover methods.
      [h1 ++ t2, h2 ++ t1 | acc]
    end)
  end

  @doc """
  Despite initializing our population to a seemingly random distribution, eventually the parents
  get too genetically similar to make any improvements during crossover. It is important to
  include the mutation step in our algorithm.

  We only want to mutate a small percentage of our population so we can preserve the progress that
  has already been made.

  ## Parameters
  - population - the current generation's population
  """
  def mutate_children(population) do
    Enum.map(population, fn chromosome ->
      # A probability of 5%
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
