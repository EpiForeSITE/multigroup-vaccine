# Initialize a `finalsize()` Parallel Worker

Internal helper that ensures a worker process can execute stochastic
[`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md)
simulations by loading the package namespace or, during local
development, the already-built shared library directly.

## Usage

``` r
initializeFinalsizeWorker(dll_path = NULL)
```

## Arguments

- dll_path:

  Optional path to the loaded `multigroup.vaccine` shared library.

## Value

`NULL`, invisibly.
