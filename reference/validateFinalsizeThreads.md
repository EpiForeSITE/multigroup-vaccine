# Validate the Number of Threads for `finalsize()`

Internal helper that validates the stochastic parallel worker count.
Sentinel values `0` and `-1` trigger auto-detection via
[`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html).

## Usage

``` r
validateFinalsizeThreads(nthreads, nsims)
```

## Arguments

- nthreads:

  Requested number of workers.

- nsims:

  Integer number of simulations after validation.

## Value

A scalar integer worker count between `1` and `nsims`.
