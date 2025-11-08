# Calculate transmission rate matrix for multi-group model with specified R0

Calculate transmission rate matrix for multi-group model with specified
R0

## Usage

``` r
transmissionRates(R0, meaninf, reltransm)
```

## Arguments

- R0:

  overall basic reproduction number

- meaninf:

  mean duration of infectious period

- reltransm:

  matrix with relative transmission rates, from column-group to
  row-group

## Value

a matrix of transmission rates to (row) and from (column) each group, in
same time units as meaninf

## Examples

``` r
transmissionRates(R0 = 15, meaninf = 7,
  reltransm = rbind(c(1, 0.5, 0.9), c(0.3, 1.9, 1), c(0.3, 0.6, 2.8)))
#>           [,1]      [,2]      [,3]
#> [1,] 0.6270422 0.3135211 0.5643380
#> [2,] 0.1881127 1.1913803 0.6270422
#> [3,] 0.1881127 0.3762253 1.7557183
```
