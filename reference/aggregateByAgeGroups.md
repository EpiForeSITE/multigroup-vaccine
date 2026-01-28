# Aggregate population counts into age groups

Aggregate per-age population counts into coarser age groups defined by
the (sorted) lower bounds in `age_groups`. When
`length(age_groups) == 1`, all ages \>= that value are aggregated into a
single open-ended group ("Xplus"). When `length(age_groups) > 1`, groups
are formed as `age_groups[i]` to `age_groups[i+1] - 1` for i = 1:(n-1)
and `age_groups[n]` and above for the final group. Human-readable labels
are produced: "under1" for the 0–0 group, "ageX" for single-year groups,
"XtoY" for ranges, and "Xplus" for the final open group. When
`verbose = TRUE`, the function prints aggregation summaries to the
console for each group using [`cat()`](https://rdrr.io/r/base/cat.html).

## Usage

``` r
aggregateByAgeGroups(ages, pops, age_groups, verbose = FALSE)
```

## Arguments

- ages:

  Numeric vector of ages (typically integers) corresponding to the
  entries in `pops`.

- pops:

  Numeric vector of population counts for each age; must be the same
  length as `ages`. Note: NA values in `pops` will propagate into group
  sums because `na.rm = TRUE` is not used; clean or impute missing
  values beforehand if required.

- age_groups:

  Numeric vector of lower bounds for desired age groups. Must be sorted
  in ascending order. If length is 1, the single value defines an
  "Xplus" group (ages \>= X). For length \> 1, contiguous
  non-overlapping groups are created as described above.

- verbose:

  Logical, if TRUE prints aggregation messages for each group. Default
  is FALSE.

## Value

A named list with components:

- pops:

  Numeric vector of aggregated population counts, one element per group.

- labels:

  Character vector of labels for each group (e.g. "under1", "age5",
  "0to4", "65plus").

- age_ranges:

  List of numeric vectors of length 2 giving the inclusive lower and
  upper bounds for each group; the upper bound for the final group is
  `Inf`.

## Details

- Group boundaries are inclusive at both ends for finite ranges (i.e.
  ages satisfying lower \<= age \<= upper). For the last group the upper
  bound is infinite.

- If no ages fall into a group the aggregated count for that group is 0
  (because `sum(numeric(0)) == 0`).

- When `verbose = TRUE`, the function writes progress messages to the
  console with [`cat()`](https://rdrr.io/r/base/cat.html) for each
  aggregated group (useful for debugging / logging). By default
  (`verbose = FALSE`), the function is silent.

## Examples

``` r
# \donttest{
# Multiple groups example
ages <- 0:100
pops <- rep(100, length(ages))
aggregateByAgeGroups(ages, pops, c(0, 5, 18, 65))
#> $pops
#> [1]  500 1300 4700 3600
#> 
#> $labels
#> [1] "0to4"   "5to17"  "18to64" "65plus"
#> 
#> $age_ranges
#> $age_ranges[[1]]
#> [1] 0 4
#> 
#> $age_ranges[[2]]
#> [1]  5 17
#> 
#> $age_ranges[[3]]
#> [1] 18 64
#> 
#> $age_ranges[[4]]
#> [1]  65 Inf
#> 
#> 

# Single open-ended group (65plus)
aggregateByAgeGroups(ages, pops, 65)
#> $pops
#> [1] 3600
#> 
#> $labels
#> [1] "65plus"
#> 
#> $age_ranges
#> $age_ranges[[1]]
#> [1]  65 Inf
#> 
#> 
# }
```
