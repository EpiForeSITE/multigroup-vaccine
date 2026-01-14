# Calculate final size of outbreak: the total number of infections in each group, by solving the analytic final size equation

Calculate final size of outbreak: the total number of infections in each
group, by solving the analytic final size equation

## Usage

``` r
getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
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
