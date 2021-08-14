defmodule Genetic.Problem.Speller do
  @moduledoc ~S"""
  Spells a target word.

  ## Examples

      Genetic.run(Genetic.Problem.Speller, target: 'Hello')

  """

  @behaviour Genetic.Problem

  @impl Genetic.Problem
  def genotype(opts \\ []) do
    target = Keyword.fetch!(opts, :target)

    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(length(target))

    %Genetic.Chromosome{genes: genes, size: length(target)}
  end

  @impl Genetic.Problem
  def calc_fitness(chromosome, opts \\ []) do
    target = List.to_string(Keyword.fetch!(opts, :target))
    guess = List.to_string(chromosome.genes)

    String.jaro_distance(target, guess)
  end

  @impl Genetic.Problem
  def terminate?([best | _], epoch, _opts \\ []) do
    epoch == 1000 || best.fitness > 0.99
  end
end
