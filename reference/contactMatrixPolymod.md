# Calculate a contact matrix for age groups based on Polymod contact survey data

Calculate a contact matrix for age groups based on Polymod contact
survey data

## Usage

``` r
contactMatrixPolymod(agelims, agepops = NULL)
```

## Arguments

- agelims:

  minimum age in years for each age group. The maximum valid age limit
  is 70, as the Polymod survey data only covers ages 0-69. Age limits
  greater than 70 will be replaced with 70 and a warning will be issued.

- agepops:

  population size of each group, defaulting to demography of Polymod
  survey population. If provided, must match the length of the age
  groups defined by `agelims` (after any adjustments for exceeding the
  70-year limit).

## Value

A symmetric contact matrix with row and column names indicating the age
groups.

## Details

The Polymod survey data only contains participants aged 0-69. Any age
limits above 70 will be adjusted to 70 with a warning, and the
corresponding populations will be aggregated into a single "70+" group.
