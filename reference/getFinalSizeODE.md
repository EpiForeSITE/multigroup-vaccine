# Calculate outbreak final size, the total number of infections in each group, by numerically solving the multi-group ordinary differential equation

Calculate outbreak final size, the total number of infections in each
group, by numerically solving the multi-group ordinary differential
equation

## Usage

``` r
getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
```

## Arguments

- transmrates:

  matrix of group-to-group (column-to-row) transmission rates

- recoveryrate:

  inverse of mean infectious period

- popsize:

  the population size of each group

- initR:

  initial number of each group already infected and removed (included in
  final size)

- initI:

  initial number of each group infectious

- initV:

  initial number of each group vaccinated
