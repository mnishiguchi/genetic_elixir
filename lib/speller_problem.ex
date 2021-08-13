defmodule SpellerProblem do
  @moduledoc """
  Spells a target word.

  ## Examples

      Genetic.run(SpellerProblem)

  """

  @behaviour Genetic.Problem

  @target 'awsome'

  @impl Genetic.Problem
  def genotype do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(length(@target))

    %Genetic.Chromosome{genes: genes, size: length(@target)}
  end

  @impl Genetic.Problem
  def calc_fitness(chromosome) do
    target = List.to_string(@target)
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl Genetic.Problem
  def terminate?([best | _]) do
    best.fitness == 1
  end
end
