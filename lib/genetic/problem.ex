defmodule Genetic.Problem do
  alias Genetic.Chromosome

  @callback genotype :: Chromosome.t()

  @callback calc_fitness(Chromosome.t()) :: number()

  @callback terminate?(Enum.t()) :: boolean()
end
