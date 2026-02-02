# multigroup.vaccine

## Overview

`multigroup.vaccine` models infectious disease dynamics in populations
with multiple distinct subgroups that can have:

- Different vaccination rates
- Different susceptibility and/or transmissibility characteristics
- Different contact rates and patterns between and within groups

The package provides both an interactive Shiny dashboard for a simple
two-group example and programmatic R functions for epidemiological
modeling and outbreak forecasting.

## Installation

### From CRAN (recommended)(when available)

``` r
install.packages("multigroup.vaccine")
```

### From R-universe

``` r
install.packages("multigroup.vaccine", 
                 repos = "https://epiforesite.r-universe.dev")
```

### From GitHub

``` r
# install.packages("remotes")
remotes::install_github("EpiForeSITE/multigroup-vaccine")
```

### Dependencies

The package depends on the following R packages:

- **Imports**: `deSolve`, `graphics`, `shiny`, `stats`, `bslib` (\>=
  0.9.0), `htmltools`, `socialmixr`
- **Suggests**: `knitr`, `rmarkdown`, `testthat` (\>= 3.0.0)

## Quick Start

### Interactive Dashboard

Launch the Shiny dashboard for interactive modeling:

``` r
library(multigroup.vaccine)
run_my_app()
```

The dashboard models two distinct sub-populations with differential
within-group and across-group contact rates and different vaccination
adherence levels. See [Nguyen et
al. (2024)](https://doi.org/10.1016/j.jval.2024.03.039) and [Duong et
al. (2026)](https://doi.org/10.1093/ofid/ofaf695.217) for more details
on this modeling approach.

### Programmatic Usage

You can also use the package functions directly in R scripts. Here’s an
example of comparing populations with different vaccination rates:

#### Two-Group Population Comparison

``` r
# Compare two populations with different vaccination rates
results <- finalsize(
  popsize = c(10000, 10000),         # Equal population sizes
  R0 = 2,                            # Basic reproduction number
  contactmatrix = matrix(1, 2, 2),   # Equal and symmetric group-to-group contact 
  relsusc = c(1, 1),                 # Equal group susceptibility per at-risk contact
  reltransm = c(1, 1),               # Equal group transmissibility per at-risk contact
  initR = c(0, 0),                   # Initially none previously infected & immune (R)
  initI = c(1, 0),                   # One initial infectious case (I) in first group
  initV = c(1000, 2000),             # Initial numbers immune by vaccination (V)
  method = "analytic"                # Solve for final size analytically
)
print(results)
```

For examples of other functions or more complex scenarios, see the
[package
vignettes](https://epiforesite.github.io/multigroup-vaccine/articles/index.html).

## Features

- **Multi-group SIR modeling** with vaccination and variable contact
  rates
- **Age-structured population models** using census data
- **Contact matrix integration** via POLYMOD-derived and custom matrices
- **Final outbreak size calculations** using both analytic and
  stochastic methods
- **Interactive Shiny dashboard** for scenario exploration

## Documentation

Comprehensive documentation and vignettes are available at:
**<https://epiforesite.github.io/multigroup-vaccine/>**

View all available vignettes:

``` r
browseVignettes("multigroup.vaccine")
```

## Core Functions

- [`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md):
  Master function for final outbreak size calculations and simulations
- [`contactMatrixPropPref()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPropPref.md):
  Generate contact matrices from proportionate mixing and preferential
  contact assumptions
- [`contactMatrixPolymod()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPolymod.md):
  Generate age-structured contact matrices from POLYMOD data
- [`getCensusData()`](https://epiforesite.github.io/multigroup-vaccine/reference/getCensusData.md):
  Download and process US Census Bureau population data for age
  group-structured models
- [`run_my_app()`](https://epiforesite.github.io/multigroup-vaccine/reference/run_my_app.md):
  Launch the interactive Shiny dashboard for a two-group model

## Getting Help

- **Bug reports**: [GitHub
  Issues](https://github.com/EpiForeSITE/multigroup-vaccine/issues)
- **Documentation**: [Package
  website](https://epiforesite.github.io/multigroup-vaccine/)

## Citation

If you use this package in your research, please obtain citation
information in R:

``` r
citation("multigroup.vaccine")
```

### Development Setup

For local development:

``` r
# Clone the repository
# git clone https://github.com/EpiForeSITE/multigroup-vaccine.git

# Install development dependencies
install.packages(c("devtools", "roxygen2", "pkgdown", "lintr"))

# Load the package for development
devtools::load_all()

# Run tests
devtools::test()

# Check package
devtools::check()
```

## License

This project is licensed under the MIT License - see the
[LICENSE.md](https://epiforesite.github.io/multigroup-vaccine/LICENSE.md)
file for details.

## Acknowledgments

This package is part of the [EpiForeSITE software
ecosystem](https://github.com/EpiForeSITE/software) developed by the
ForeSITE Group at the University of Utah. Development was supported by
the Centers for Disease Control and Prevention’s Center for Forecasting
and Outbreak Analytics (Cooperative agreement CDC-RFA-FT-23-0069).
