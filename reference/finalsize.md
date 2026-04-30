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
  nsims = 1,
  nthreads = 1,
  cluster = NULL,
  seed = NULL
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

- nthreads:

  the number of threads (parallel workers) to use for stochastic
  simulations. Defaults to 1 (single-threaded). Set to 0 or -1 to
  automatically use all available cores. Ignored for
  `method = "hybrid"`.

- cluster:

  an optional
  [`parallel cluster`](https://rdrr.io/r/parallel/makeCluster.html)
  object to use for stochastic simulations. When supplied, `nthreads` is
  ignored, allowing callers to provide PSOCK, FORK, MPI, or
  scheduler-managed clusters. Ignored for `method = "hybrid"`.

- seed:

  optional integer base random seed for stochastic methods. When
  supplied, `finalsize()` is reproducible for that seed regardless of
  `nthreads` and independent of caller RNG state.

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
#>        R1  R2
#>  [1,]   1   0
#>  [2,]   1   0
#>  [3,]   1   1
#>  [4,]   1   0
#>  [5,]   1   0
#>  [6,] 390  85
#>  [7,] 441 106
#>  [8,] 349  77
#>  [9,]   5   0
#> [10,]   1   0
# All "escaped" outbreaks set to deterministic final size:
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
method = "hybrid", nsims = 10)
#>       [,1] [,2]
#>  [1,]    2    1
#>  [2,]    1    0
#>  [3,]  412  103
#>  [4,]    6    1
#>  [5,]   10    1
#>  [6,]    1    0
#>  [7,]    1    0
#>  [8,]    1    0
#>  [9,]  412  103
#> [10,]  412  103
# Stochastic runs can be reproduced directly with seed:
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
method = "stochastic", nsims = 10, nthreads = 2, seed = 2026)
#>        R1  R2
#>  [1,]  21   3
#>  [2,]   1   0
#>  [3,] 469 121
#>  [4,] 441 107
#>  [5,] 402  90
#>  [6,]   1   0
#>  [7,]  10   0
#>  [8,] 425 108
#>  [9,]   1   2
#> [10,] 414 112
# Parallel stochastic simulations are available for interactive use, but are
# omitted from examples to avoid spawning worker processes during R CMD check.
```
