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

## Value

vector of final sizes (number of infected over whole outbreak) for each
group

## Examples

``` r
getFinalSizeAnalytic(transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#> [1] 31.46733 49.59954
```
