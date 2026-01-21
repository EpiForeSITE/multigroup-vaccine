# Calculate outbreak size at a given time

Calculate outbreak size at a given time

## Usage

``` r
getSizeAtTime(time, transmrates, recoveryrate, popsize, initR, initI, initV)
```

## Arguments

- time:

  the time at which to calculate the outbreak size

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

a list with totalSize (total cumulative infections) and activeSize
(total currently infected) in each group at the specified time

## Examples

``` r
getSizeAtTime(time = 30, transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#> $totalSize
#> [1]  8.904003 14.751738
#> 
#> $activeSize
#> [1] 1.533286 2.368198
#> 
```
