# Calculate final outbreak size or distribution of a multigroup transmission model for a given basic reproduction number, contact/transmission assumptions, and initial conditions

Calculate final outbreak size or distribution of a multigroup
transmission model for a given basic reproduction number,
contact/transmission assumptions, and initial conditions

## Usage

``` r
finalsize(
  popsize,
  R0,
  contactmatrix,
  relsusc,
  reltransm,
  initR,
  initI,
  initV,
  method = "ODE",
  nsims = 1
)
```

## Arguments

- popsize:

  the population size of each group

- R0:

  the basic reproduction number

- contactmatrix:

  matrix of group-to-group contact rates

- relsusc:

  relative susceptibility to infection per contact of each group

- reltransm:

  relative transmissibility per contact of each group

- initR:

  initial number of each group already infected and removed (included in
  size result)

- initI:

  initial number of each group infectious

- initV:

  initial number of each group vaccinated

- method:

  the method of final size calculation or simulation to use

- nsims:

  the number of simulations to run for stochastic methods

## Value

a matrix with the final number infected from each group (column) in each
simulation (row)
