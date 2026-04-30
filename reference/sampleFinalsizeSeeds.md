# Sample Per-simulation Seeds for `finalsize()`

Internal helper that generates one RNG seed per stochastic simulation.
When `seed` is supplied, sampling is performed in a local RNG context so
the caller RNG state is not modified.

## Usage

``` r
sampleFinalsizeSeeds(nsims, seed = NULL)
```

## Arguments

- nsims:

  Integer simulation count.

- seed:

  Optional integer base seed.

## Value

Integer vector of length `nsims`.
