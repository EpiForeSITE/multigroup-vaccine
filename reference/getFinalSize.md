# Calculate final size of outbreak: the total number of infections in each group

Calculate final size of outbreak: the total number of infections in each
group

## Usage

``` r
getFinalSize(
  vacTime,
  vacPortion,
  popSize,
  R0,
  recoveryRate,
  relContact,
  contactWithinGroup,
  relSusc
)
```

## Arguments

- vacTime:

  time after first case at which all vaccinations are delivered

- vacPortion:

  fraction of each population vaccinated

- popSize:

  size of each population

- R0:

  overall basic reproduction number

- recoveryRate:

  inverse of mean infectious period (same time units as vacTime)

- relContact:

  relative overall contact rate of each group

- contactWithinGroup:

  fraction of each group's contacts that are in-group vs out-group

- relSusc:

  relative susceptibility to infection per contact of each group
