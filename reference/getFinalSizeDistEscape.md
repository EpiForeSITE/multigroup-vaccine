# Estimate the distribution of final outbreak sizes by group using a hybrid model: stochastic simulations for smaller-sized outbreaks and deterministic ordinary differential equation model for "escaped" outbreaks

Estimate the distribution of final outbreak sizes by group using a
hybrid model: stochastic simulations for smaller-sized outbreaks and
deterministic ordinary differential equation model for "escaped"
outbreaks

## Usage

``` r
getFinalSizeDistEscape(
  n,
  transmrates,
  recoveryrate,
  popsize,
  initR,
  initI,
  initV
)
```

## Arguments

- n:

  the number of simulations to run

- transmrates:

  matrix of group-to-group (column-to-row) transmission rates

- recoveryrate:

  inverse of mean infectious period

- popsize:

  the population size of each group

- initR:

  initial number of each group already infected and removed (included in
  size result)

- initI:

  initial number of each group infectious

- initV:

  initial number of each group vaccinated

## Value

a matrix with the final number infected from each group (column) in each
simulation (row)
