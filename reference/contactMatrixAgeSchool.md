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
