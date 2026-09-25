# Calculate a contact matrix for age groups and schools

Calculate a contact matrix for age groups and schools

## Usage

``` r
contactMatrixAgeSchool(
  agelims,
  agepops,
  schoolagegroups,
  schoolpops,
  schportion
)
```

## Arguments

- agelims:

  minimum age in years for each age group

- agepops:

  population size of each age group

- schoolagegroups:

  index of the age group covered by each school

- schoolpops:

  population size of each school

- schportion:

  portion of within-age-group contacts that are exclusively within
  school

## Value

a square matrix with the contact rate of each group (row) with members
of each other group (column)

## Examples

``` r
contactMatrixAgeSchool(agelims = c(0, 5, 18), agepops = c(500, 1300, 8200),
schoolagegroups = c(2, 2), schoolpops = c(600, 700), schportion = 0.7)
#>            under5   5to17s1   5to17s2       18+
#> under5  2.2280800 0.6201380 0.7234943  6.167205
#> 5to17s1 0.5167817 7.4135815 1.4283047  7.418992
#> 5to17s2 0.5167817 1.2242612 7.6176251  7.418992
#> 18+     0.3760491 0.5428531 0.6333286 11.030196
```
