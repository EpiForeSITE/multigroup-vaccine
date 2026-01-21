# Calculate reproduction number for a multigroup model with a given state of vaccination and immunity

Calculate reproduction number for a multigroup model with a given state
of vaccination and immunity

## Usage

``` r
vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
```

## Arguments

- meaninf:

  mean infectious period with same time units as trmat

- popsize:

  the population size of each group

- trmat:

  matrix of group-to-group (column-to-row) transmission rates

- initR:

  initial number of each group already infected and immune

- initV:

  initial number of each group vaccinated

- vaxeff:

  effectiveness (0 to 1) of vaccine in producing immunity to infection

## Value

the reproduction number

## Examples

``` r
meaninf <- 7
popsize <- c(200, 800)
initR <- c(0, 0)
initV <- c(0, 0)
vaxeff <- 1
trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
#> [1] 9.025329
vaxrepnum(meaninf, popsize, trmat, initR, initV = c(160, 750), vaxeff)
#> [1] 0.9641501
```
