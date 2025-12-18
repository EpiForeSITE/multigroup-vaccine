# Calculate final size of outbreak: the total number of infections in each group, by solving the analytic final size equation

Calculate final size of outbreak: the total number of infections in each
group, by solving the analytic final size equation

## Usage

``` r
getFinalSizeAnalytic(Rinit, Iinit, Vinit, N, R0, a, eps, q)
```

## Arguments

- Rinit:

  initial number already infected, recovered, and immune in each group

- Iinit:

  initial number actively infectious in each group

- Vinit:

  initial number vaccinated and immunized in each group

- N:

  population size of each group

- R0:

  overall basic reproduction number

- a:

  relative overall contact rate of each group

- eps:

  fraction of each group's contacts that exclusively within-group

- q:

  relative susceptibility to infection per contact of each group
