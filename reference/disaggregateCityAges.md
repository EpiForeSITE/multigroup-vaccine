# Disaggregate ACS 5-year age groups into single-year ages

Takes population counts from ACS 5-year age groupings and uniformly
distributes them into single-year ages. This allows for more flexible
age group aggregations.

## Usage

``` r
disaggregateCityAges(acs_age_pops)
```

## Arguments

- acs_age_pops:

  Numeric vector of length 18 containing populations for ACS age groups:
  0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-44, 45-49,
  50-54, 55-59, 60-64, 65-69, 70-74, 75-79, 80-84, 85+

## Value

A list containing:

- ages:

  Vector of single-year ages (0, 1, 2, ..., 85)

- age_pops:

  Vector of populations for each single year

- age_labels:

  Vector of labels for each age
