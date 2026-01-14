# Ordinary differential equation function for multi-group susceptible-infectious-removed (SIR) model used as "func" argument passed to the ode() function from deSolve package

Ordinary differential equation function for multi-group
susceptible-infectious-removed (SIR) model used as "func" argument
passed to the ode() function from deSolve package

## Usage

``` r
odeSIR(time, state, par)
```

## Arguments

- time:

  vector of times at which the function will be evaluated

- state:

  vector of number of individuals in each group at each state: S states
  followed by I states followed by R states

- par:

  vector of parameter values: group-to-group transmission rate matrix
  elements (row-wise) followed by recovery rate
