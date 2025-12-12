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
  is 90, as the socialmixr contact_matrix function supports ages up
  to 90. Age limits greater than 90 will be replaced with 90 and a
  warning will be issued.

- agepops:

  population size of each group, defaulting to demography of Polymod
  survey population. If provided, must match the length of the age
  groups defined by `agelims` (after any adjustments for exceeding the
  90-year limit).

## Value

A symmetric contact matrix with row and column names indicating the age
groups.

## Details

The socialmixr contact_matrix function supports age limits up to 90. Any
age limits above 90 will be adjusted to 90 with a warning, and the
corresponding populations will be aggregated into a single "90+" group.
