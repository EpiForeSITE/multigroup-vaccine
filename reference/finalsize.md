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

a vector (nsims = 1) or matrix (nsims \> 1) with the final number
infected from each group (column) in each simulation (row)

## Examples

``` r
popsize <- c(800, 200)
R0 <- 2
contactmatrix <- contactMatrixPropPref(popsize = popsize, contactrate = c(1, 1),
ingroup = c(0.2, 0.2))
relsusc <- c(1, 1)
reltransm <- c(1, 1)
initR <- c(0, 0)
initI <- c(1, 0)
initV <- 0.2 * popsize
# Default method "ODE" numerical solves ordinary differential equations until infectious count
# is close to 0
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
#> [1] 411.6173 102.8034
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
method = "analytic")
#> [1] 411.6174 102.8034
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
method = "stochastic", nsims = 10)
#>       [,1] [,2]
#>  [1,]  424  114
#>  [2,]  402   98
#>  [3,]    1    0
#>  [4,]    1    0
#>  [5,]    1    0
#>  [6,]    1    0
#>  [7,]    1    0
#>  [8,]    2    1
#>  [9,]    6    0
#> [10,]    1    0
# All "escaped" outbreaks set to deterministic final size:
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
method = "hybrid", nsims = 10)
#>       [,1] [,2]
#>  [1,]  412  103
#>  [2,]  412  103
#>  [3,]  412  103
#>  [4,]  412  103
#>  [5,]    1    0
#>  [6,]    4    1
#>  [7,]  412  103
#>  [8,]    1    0
#>  [9,]  412  103
#> [10,]  412  103
```
