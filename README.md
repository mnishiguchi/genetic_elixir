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
