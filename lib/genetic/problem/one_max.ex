defmodule Genetic.Problem.OneMax do
  @moduledoc """
  The one-max problem
  - Question: What is the maximum sum of a bitstring of length N?
  - Answer: N

  ## Examples

      Genetic.run(Genetic.Problem.OneMax)

  """

  @behaviour Genetic.Problem

  @bitstring_length 42

  @impl Genetic.Problem
  def genotype do
    genes = for _ <- 1..@bitstring_length, do: Enum.random(0..1)
    %Genetic.Chromosome{genes: genes, size: @bitstring_length}
  end

  @impl Genetic.Problem
  def calc_fitness(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl Genetic.Problem
  def terminate?([best | _]) do
    best.fitness == @bitstring_length
  end
end
