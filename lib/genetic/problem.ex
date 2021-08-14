defmodule Genetic.Problem do
  alias Genetic.Chromosome

  @callback genotype(opts :: keyword()) :: Chromosome.t()

  @callback calc_fitness(Chromosome.t(), opts :: keyword()) :: number()

  @callback terminate?(Enum.t(), epoch :: integer(), opts :: keyword()) :: boolean()
end
