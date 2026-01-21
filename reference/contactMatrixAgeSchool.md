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
#> under5  2.2518104 0.6218986 0.7255483  6.198479
#> 5to17s1 0.5182488 7.3923228 1.4242090  7.406912
#> 5to17s2 0.5182488 1.2207506 7.5957812  7.406912
#> 18+     0.3779560 0.5419691 0.6322973 11.028652
```
