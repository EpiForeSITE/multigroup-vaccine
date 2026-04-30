# Validate Optional RNG Seed for `finalsize()`

Internal helper that validates an optional user-provided RNG seed used
to make stochastic simulations reproducible independent of global RNG
state.

## Usage

``` r
validateFinalsizeSeed(seed)
```

## Arguments

- seed:

  Optional seed value provided by the caller.

## Value

`NULL` or a scalar integer seed.
