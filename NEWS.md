# multigroup.vaccine 0.1.0

## Initial Release

This is the initial release of the multigroup.vaccine package, providing tools for examining the effects of differential rates of vaccination in populations with different sizes, contact rates, and other epidemiological parameters.

### Key Features

* **Multi-group vaccine modeling framework**
  - `getFinalSize()`: Calculate final size of outbreak across multiple population groups
  - `transmissionRates()`: Calculate transmission rate matrix for multi-group models with specified R0
  - `getFinalSizeODE()`: Calculate outbreak final size by numerically solving multi-group ODEs
  - `getFinalSizeDist()`: Estimate distribution of final outbreak sizes using stochastic simulations
  - `getSizeAtTime()`: Calculate outbreak size at a given time point

* **Interactive Shiny Application**
  - `run_my_app()`: Launch interactive Shiny app for exploring vaccine model scenarios
  - Visualize effects of differential vaccination rates across population groups
  - Examine impact of contact patterns and disease parameters on outbreak outcomes

* **Census Data Integration**
  - `getCensusData()`: Download and process U.S. Census Bureau population estimates by age and county
  - `getCensusDataPath()`: Get path to example census data file
  - `getStateFIPS()`: Look up state FIPS codes
  - `listCounties()`: List available counties for a state
  - Support for age-structured populations with optional sex disaggregation
  - Built-in caching for downloaded census files

* **Contact Matrix Functionality**
  - Integration with POLYMOD contact survey data via `socialmixr` package
  - Age-structured contact matrices for realistic epidemic modeling
  - Flexible age group specifications

* **Example Data**
  - `UtahAgeCountyPop`: Population estimates by age group for all Utah counties (2024)

### Vignettes

* **Contact Matrix Examples**: Demonstrates how to use POLYMOD contact matrices with the vaccine model
* **Comparison to epiworld**: Compares model outputs with the epiworldR simulation framework
* **Measles Age-Structured Model**: Example application to measles outbreak modeling with age groups

### Testing

* Comprehensive tests using testthat framework
* Tests for final size calculations with different vaccination scenarios (immediate and delayed)
* Tests for transmission rate calibration with multi-group populations

### Infrastructure

* GitHub Actions CI/CD with R CMD check across multiple platforms (macOS, Windows, Ubuntu)
* Pre-commit hooks for code formatting (styler) and linting (lintr)
* pkgdown website: https://epiforesite.github.io/multigroup-vaccine/
* MIT License
* Funded by CDC's Center for Forecasting and Outbreak Analytics (CDC-RFA-FT-23-0069)
