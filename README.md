# Genetic algorithm

https://pragprog.com/titles/smgaelixir/genetic-algorithms-in-elixir/

- optimization or the search for the best
- balance between exploration and exploitation (using known info)
- crossover:
  - the process of creating new child solutions from parent solutions
- premature convergence:
  - a common pitfall
  - some solutions appear to be good enough even though better solutions exist

## Genetic algorithm structure

- Each step performs a transformation on the population that brings you closer to finding a solution
- The process is repeated until a solution is found

```
- initialize population
- evaluate population
- select parents
- create children
- mutate children
```

## Chromosomes

- represents solutions to problems

## Hyperparameters

- the parts of the algorithm you set before the algorithm starts training
- population size, mutation rate, etc
- To ensure you can change hyperparameters without too much of a headache, you need to implement a simple configuration mechanism into your framework that separates the hyperparameters from the overall structure of the algorithm.

## Elitism selection

- Because the population is sorted by the fitness, the strongest chromosomes will reproduce with
other strong chromosomes.

## Crossover

- The goal of crossover is to exploit the strength of current solutions to find new better solutions.
