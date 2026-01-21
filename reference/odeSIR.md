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

## Value

a list of three vectors of derivatives dS, dI, and dR for each group,
evaluated at the given state values

## Examples

``` r
# Intended only for use as the func argument to the ode() function from the deSolve package:
y0 <- c(S1 = 79999, S2 = 20000, I1 = 1, I2 = 0, R1 = 0, R2 = 0)
parms <- c(beta11 = 1.6e-6, beta21 = 1.5e-6, beta12 = 1.4e-6, beta22 = 8.7e-6, recoveryrate = 1/7)
times <- seq(0, 350, len = 10)
deSolve::ode(y0, times, odeSIR, parms)
#>         time       S1        S2          I1           I2          R1
#> 1    0.00000 79999.00 20000.000    1.000000    0.0000000     0.00000
#> 2   38.88889 79984.16 19989.787    4.975792    3.6986953    10.86294
#> 3   77.77778 79771.32 19828.414   74.789785   56.6351586   153.88662
#> 4  116.66667 76939.51 17797.233  934.695537  653.2043915  2125.79825
#> 5  155.55556 63215.65 10509.650 2913.095501 1316.4542701 13871.25231
#> 6  194.44444 52939.96  7091.470 1192.639210  343.1435922 25867.40030
#> 7  233.33333 50542.72  6483.209  234.716452   57.3523993 29222.56349
#> 8  272.22222 50124.64  6384.202   39.798837    9.3542408 29835.56224
#> 9  311.11111 50055.32  6368.013    6.567328    1.5317087 29938.11225
#> 10 350.00000 50043.93  6365.358    1.078526    0.2511921 29954.99428
#>              R2
#> 1      0.000000
#> 2      6.514157
#> 3    114.950838
#> 4   1549.562676
#> 5   8173.895260
#> 6  12565.386624
#> 7  13459.438235
#> 8  13606.443445
#> 9  13630.455665
#> 10 13634.390347
```
