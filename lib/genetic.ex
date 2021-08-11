defmodule Genetic do
  @moduledoc """
  Generalized genetic framework.
  """

  # one hundred is sufficient for most genetic algorithms
  @default_population_size 100

  @doc """
  ## Examples

      genotype_fun = fn -> for _ <- 1..1000, do: Enum.random(0..1) end
      fitness_fun = fn chromosome -> Enum.sum(chromosome) end
      Genetic.run(genotype_fun, fitness_fun, 1000)

  """
  def run(genotype_fun, fitness_fun, max_fitness, hyperparameters \\ []) do
    initialize(genotype_fun)
    |> evolve(fitness_fun, max_fitness, hyperparameters)
  end

  @doc """
  Creates a list of possible solutions.

  Typically, the more chromosomes you have, the longer it takes to perform transformations on the
  entire population. Conversely, the fewer chromosomes you have, the longer it takes to produce a
  viable solution to our problem and the more susceptible our population is to premature
  convergence.
  """
  def initialize(genotype_fun, hyperparameters \\ []) do
    population_size = hyperparameters[:population_size] || @default_population_size
    for _ <- 1..population_size do
      genotype_fun.()
    end
  end

  @doc """
  """
  def evolve(population, fitness_fun, max_fitness, hyperparameters \\ []) do
    population = evaluate(population, fitness_fun, hyperparameters)
    best = hd(population)
    IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

    if Enum.sum(best) == max_fitness do
      # Base case (termination criteria)
      best
    else
      # Recursive case
      population
      |> select(hyperparameters)
      |> crossover(hyperparameters)
      |> mutate(hyperparameters)
      |> evolve(fitness_fun, max_fitness, hyperparameters)
    end
  end

  @doc """
  Sorts a population by fitness. The fitness function can return anything as long as the fitness
  can be sorted.
  """
  def evaluate(population, fitness_fun, hyperparameters \\ []) do
    population
    # Sort the population in descending order
    |> Enum.sort_by(fitness_fun, &>=/2)
  end

  @doc """
  Formats the chromosomes nicely for crossover.
  """
  def select(population, hyperparameters \\ []) do
    population
    |> Enum.chunk_every(2)
    # Tuples are easier to work with in the next step.
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Takes two or more parent chromosomes and produces two or more child chromosomes.
  """
  def crossover(population, hyperparameters \\ []) do
    population
    |> Enum.reduce([], fn {parent1, parent2}, acc ->
      # A random crossover point (uniform integer between 0 and N-1)
      cx_point = :rand.uniform(length(parent1))

      {h1, t1} = Enum.split(parent1, cx_point)
      {h2, t2} = Enum.split(parent2, cx_point)

      # Single-point crossover is one of the simplest crossover methods.
      [h1 ++ t2, h2 ++ t1 | acc]
    end)
  end

  @doc """
  Despite initializing our population to a seemingly random distribution, eventually the parents
  get too genetically similar to make any improvements during crossover. It is important to
  include the mutation step in our evolve.

  We only want to mutate a small percentage of our population so we can preserve the progress that
  has already been made.

  """
  def mutate(population, hyperparameters \\ []) do
    population
    |> Enum.map(fn chromosome ->
      # A probability of 5%
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
