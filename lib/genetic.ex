defmodule Genetic do
  @moduledoc """
  Generalized genetic framework.
  """

  # one hundred is sufficient for most genetic algorithms
  @default_population_size 100

  @doc """
  Runs the algorithm.

  ## Examples

      iex> Genetic.run(Genetic.Problem.OneMax)
      Current Best: 1000

  """
  def run(problem_mod, hyperparameters \\ [])
      when is_atom(problem_mod) and is_list(hyperparameters) do
    initialize(&problem_mod.genotype/0)
    |> evolve(problem_mod, hyperparameters)
  end

  @doc """
  Creates a list of chromosomes (possible solutions) using a specified genotype function.
  """
  def initialize(genotype_fun, hyperparameters \\ [])
      when is_function(genotype_fun) and is_list(hyperparameters) do
    population_size = hyperparameters[:population_size] || @default_population_size

    for _ <- 1..population_size do
      genotype_fun.()
    end
  end

  @doc """
  Models a single evoluton in the genetic algorithm. The process is repeated until a solution is
  found.
  """
  def evolve(chromosomes, problem_mod, hyperparameters \\ [])
      when is_list(chromosomes) and is_atom(problem_mod) and is_list(hyperparameters) do
    chromosomes = evaluate(chromosomes, &problem_mod.calc_fitness/1, hyperparameters)
    best = hd(chromosomes)
    IO.write("\rCurrent Best: #{best.fitness}")

    if problem_mod.terminate?(chromosomes) do
      # Base case
      IO.write "\n"
      best
    else
      # Recursive case
      chromosomes
      |> select(hyperparameters)
      |> crossover(hyperparameters)
      |> mutate(hyperparameters)
      |> evolve(problem_mod, hyperparameters)
    end
  end

  @doc """
  Sorts the chromosomes by fitness. The fitness function can return anything as long as the fitness
  can be sorted.
  """
  def evaluate(chromosomes, fitness_fun, hyperparameters \\ [])
      when is_list(chromosomes) and is_function(fitness_fun) and is_list(hyperparameters) do
    chromosomes
    |> Enum.map(fn chromosome ->
      fitness = fitness_fun.(chromosome)
      age = chromosome.age + 1
      %Genetic.Chromosome{chromosome | fitness: fitness, age: age}
    end)
    # Sort the chromosomes in descending order
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  @doc """
  Formats the chromosomes nicely for crossover.
  """
  def select(chromosomes, hyperparameters \\ [])
      when is_list(chromosomes) and is_list(hyperparameters) do
    chromosomes
    |> Enum.chunk_every(2)
    # Tuples are easier to work with in the next step.
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Reproduces chromosomes for the better, exploiting the strength of current chromosomes.
  """
  def crossover(chromosomes, hyperparameters \\ [])
      when is_list(chromosomes) and is_list(hyperparameters) do
    chromosomes
    |> Enum.reduce(
      [],
      fn {parent1, parent2}, acc ->
        # A random crossover point (uniform integer between 0 and N-1)
        cx_point = :rand.uniform(length(parent1.genes))

        # Single-point crossover is one of the simplest crossover methods.
        {h1, t1} = Enum.split(parent1.genes, cx_point)
        {h2, t2} = Enum.split(parent2.genes, cx_point)
        child1 = %Genetic.Chromosome{parent1 | genes: h1 ++ t2}
        child2 = %Genetic.Chromosome{parent2 | genes: h2 ++ t1}

        [child1, child2 | acc]
      end
    )
  end

  @doc """
  Shuffles 5% of the chromosomes.
  """
  def mutate(chromosomes, hyperparameters \\ [])
      when is_list(chromosomes) and is_list(hyperparameters) do
    chromosomes
    |> Enum.map(fn chromosome ->
      # A probability of 5%
      if :rand.uniform() < 0.05 do
        %Genetic.Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
