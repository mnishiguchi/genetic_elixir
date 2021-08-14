defmodule Genetic.Problem.Cargo do
  @moduledoc ~S"""
  This is a modification of the knapsack problem. The knapsack problem belongs to a class of
  optimization problems known as constraint satisfaction problems.

  ## Examples

      run_cargo_problem = fn ->
        solution = Genetic.run(Genetic.Problem.Cargo)

        weight = Genetic.Problem.Cargo.calc_weight(solution)
        profit = Genetic.Problem.Cargo.calc_profit(solution)

        IO.write("\n")
        IO.inspect(profit, label: "profit")
        IO.inspect(weight, label: "weight")
        IO.write("\n")

        solution
      end

      run_cargo_problem.()

  """

  @behaviour Genetic.Problem

  @chromosome_size 10
  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  @weight_limit 40

  @impl Genetic.Problem
  def genotype(opts \\ []) do
    genes =
      for _ <- 1..@chromosome_size do
        Enum.random(0..1)
      end

    %Genetic.Chromosome{genes: genes, size: @chromosome_size}
  end

  @impl Genetic.Problem
  def calc_fitness(chromosome, opts \\ []) do
    _profits =
      if calc_weight(chromosome) > @weight_limit do
        # A penalty
        0
      else
        calc_profit(chromosome)
      end
  end

  def calc_profit(chromosome) do
    chromosome.genes
    |> Enum.zip(@profits)
    |> Enum.map(fn {gene, profit} -> gene * profit end)
    |> Enum.sum()
  end

  def calc_weight(chromosome) do
    chromosome.genes
    |> Enum.zip(@weights)
    |> Enum.map(fn {gene, weight} -> gene * weight end)
    |> Enum.sum()
  end

  @impl Genetic.Problem
  def terminate?(_population, epoch, opts \\ []) do
    epoch == 1000
  end
end
