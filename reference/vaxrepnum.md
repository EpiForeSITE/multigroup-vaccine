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
