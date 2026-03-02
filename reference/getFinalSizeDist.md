# Estimate the distribution of final outbreak sizes by group using stochastic simulations of multi-group model

Estimate the distribution of final outbreak sizes by group using
stochastic simulations of multi-group model

## Usage

``` r
getFinalSizeDist(n, transmrates, recoveryrate, popsize, initR, initI, initV)
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

## Examples

``` r
getFinalSizeDist(n = 10, transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#>       [,1] [,2]
#>  [1,]    0    1
#>  [2,]    0    1
#>  [3,]    0    1
#>  [4,]    0    1
#>  [5,]    0    1
#>  [6,]    0    2
#>  [7,]    0    1
#>  [8,]    9   17
#>  [9,]    0    1
#> [10,]    5   19
```
