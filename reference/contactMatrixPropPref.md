# Calculate group contact matrix with proportional mixing and preferential mixing within group

Calculate group contact matrix with proportional mixing and preferential
mixing within group

## Usage

``` r
contactMatrixPropPref(popsize, contactrate, ingroup)
```

## Arguments

- popsize:

  population size of each group

- contactrate:

  overall contact rate of each group

- ingroup:

  fraction of each group's contacts that are exclusively in-group

## Value

a square matrix with the contact rate of each group (row) with members
of each other group (column)

## Examples

``` r
contactMatrixPropPref(popsize = c(100, 150, 200), contactrate = c(1.1, 1, 0.9),
ingroup = c(0.2, 0.25, 0.22))
#>           [,1]      [,2]      [,3]
#> [1,] 0.4471634 0.2904077 0.3624289
#> [2,] 0.1936052 0.4975066 0.3088882
#> [3,] 0.1812144 0.2316662 0.4871194
```
