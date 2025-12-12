
<!-- README.md is generated from README.Rmd. Please edit that file -->

# multigroup.vaccine

<!-- badges: start -->

[![R-CMD-check](https://github.com/EpiForeSITE/multigroup-vaccine/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiForeSITE/multigroup-vaccine/actions/workflows/R-CMD-check.yaml)
[![R-universe](https://epiforesite.r-universe.dev/badges/multigroup.vaccine)](https://epiforesite.r-universe.dev/multigroup.vaccine)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![EpiForeSITE](https://img.shields.io/badge/Part%20of-EpiForeSITE-blue.svg)](https://github.com/EpiForeSITE/software)
<!-- badges: end -->

## Overview

`multigroup.vaccine` models infectious disease dynamics in populations
with multiple distinct subgroups that have:

- Different vaccination rates
- Different vaccine effectiveness
- Differential contact patterns between and within groups

The package provides both an interactive Shiny dashboard and
programmatic R functions for epidemiological modeling and outbreak
forecasting.

## Installation

### From R-universe (Recommended)

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
  0.8.0), `htmltools`, `socialmixr`
- **Suggests**: `knitr`, `rmarkdown`, `testthat` (\>= 3.0.0), `ggplot2`,
  `epiworldR`

Note that some vignettes require `ggplot2` and other suggested packages.

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
al. (2024)](https://doi.org/10.1016/j.jval.2024.03.039) for more details
on this modeling approach.

### Programmatic Usage

You can also use the package functions directly in R scripts. Here’s an
example of comparing populations with different vaccination rates:

#### Two-Group Population Comparison

``` r
# Compare populations with different vaccination rates
results <- getFinalSize(
  vacPortion = c(0.9, 0.3),      # 90% vs 30% vaccinated
  popSize = c(10000, 10000),      # Equal population sizes
  R0 = 15,                        # Basic reproduction number
  recoveryRate = 0.1,             # 1/recovery rate = 10 days
  relContact = 0.05,              # 5% contact between groups
  contactWithinGroup = c(0.8, 0.8), # 80% within-group contact
  relSusc = c(0.1, 1)            # 10% relative susceptibility if vaccinated
)

print(results)
```

## Features

- **Multi-group SIR modeling** with vaccination and variable contact
  rates
- **Age-structured population models** using census data
- **Contact matrix integration** via POLYMOD and custom matrices
- **Final outbreak size calculations** using both analytic and
  stochastic methods
- **Interactive Shiny dashboard** for scenario exploration
- **Real-world case studies** including measles outbreaks with census
  data

## Documentation

Comprehensive documentation and vignettes are available at:
**<https://epiforesite.github.io/multigroup-vaccine/>**

View all available vignettes:

``` r
browseVignettes("multigroup.vaccine")
```

## Core Functions

- `getOutputTable()`: Run age-structured outbreak simulations with
  vaccination
- `getFinalSize()`: Calculate final outbreak size for two-group
  populations
- `getFinalSizeDist()`: Stochastic outbreak simulations with
  distributional results
- `transmissionRates()`: Calculate transmission rate matrices from R0
  and contact patterns
- `contactMatrixPolymod()`: Generate age-structured contact matrices
  from POLYMOD data
- `getCensusData()`: Download and process US Census Bureau population
  data
- `run_my_app()`: Launch the interactive Shiny dashboard

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
[LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

This package is part of the [EpiForeSITE software
ecosystem](https://github.com/EpiForeSITE/software) developed by the
ForeSITE Group at the University of Utah. Development was supported by
the Centers for Disease Control and Prevention’s Center for Forecasting
and Outbreak Analytics (Cooperative agreement CDC-RFA-FT-23-0069).

------------------------------------------------------------------------

**EpiForeSITE**: Epidemiological Forecasting and Scenario Modeling
Initiative for Translational Epidemiology
