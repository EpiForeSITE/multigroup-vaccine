# multigroup.vaccine (development version)

# multigroup.vaccine 0.1.0

Initial release of multigroup.vaccine, a package for examining the effects of differential vaccination rates in populations with different sizes, contact rates, and other epidemiological parameters.

## New features

* Multi-group vaccine modeling functions: `getFinalSize()`, `transmissionRates()`, `getFinalSizeODE()`, `getFinalSizeDist()`, and `getSizeAtTime()`.

* Interactive Shiny application via `run_my_app()` for exploring vaccine scenarios and visualizing effects of differential vaccination rates across population groups.

* U.S. Census data integration: `getCensusData()` downloads and processes Census Bureau population estimates by age and county, with support for age-structured populations, sex disaggregation, and built-in caching. Helper functions include `getCensusDataPath()`, `getStateFIPS()`, and `listCounties()`.

* Contact matrix functionality using POLYMOD contact survey data via the `socialmixr` package for realistic age-structured epidemic modeling.

* Example dataset `UtahAgeCountyPop` with 2024 population estimates by age group for all Utah counties.

## Vignettes

* Contact Matrix Examples
* Comparison to epiworld
* Measles Age-Structured Model
