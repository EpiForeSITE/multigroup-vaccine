# Multigroup Vaccine Model

[![ForeSITE
Group](https://github.com/EpiForeSITE/software/raw/e82ed88f75e0fe5c0a1a3b38c2b94509f122019c/docs/assets/foresite-software-badge.svg)](https://github.com/EpiForeSITE)

## Getting Started

This R package models the behavior of a population with two distinct
sub-populations that interact differentially between within-group and
across-group rates and that have different rates of vaccine adherence.

### Prerequisites

### Installing

Install the package from github using the
[remotes](https://cran.r-project.org/package=remotes) package, then run
the Shiny application with the run_my_app() function.

``` r
remotes::install_github("EpiForeSITE/multigroup-vaccine")
multigroup.vaccine::run_my_app()
```

### Usage

Change the values in the population setup and disease parameters panel
to see the effects on the outcomes for the two sub-populations. ![Screen
shot of Multigroup Vaccine
Application](https://raw.githubusercontent.com/EpiForeSITE/multigroup-vaccine/refs/heads/main/inst/app/www/figs/screenshot.PNG)

## License

This project is licensed under the
[MIT](https://epiforesite.github.io/multigroup-vaccine/LICENSE.md)
License - see the
[LICENSE.md](https://epiforesite.github.io/multigroup-vaccine/LICENSE.md)
file for details.
