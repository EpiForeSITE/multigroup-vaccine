# Changelog

## multigroup.vaccine (development version)

## multigroup.vaccine 0.1.1

- Fixed bug in
  [`contactMatrixPolymod()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPolymod.md)
  where age limits exceeding 90 caused dimension mismatch errors. The
  function now warns and automatically adjusts age limits to 90,
  aggregating corresponding populations into the 90+ group. (#39)

## multigroup.vaccine 0.1.0

Initial release of multigroup.vaccine, a package for examining the
effects of differential vaccination rates in populations with different
sizes, contact rates, and other epidemiological parameters.

### New features

- Multi-group vaccine modeling functions:
  [`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md),
  [`transmissionRates()`](https://epiforesite.github.io/multigroup-vaccine/reference/transmissionRates.md),
  [`getFinalSizeODE()`](https://epiforesite.github.io/multigroup-vaccine/reference/getFinalSizeODE.md),
  [`getFinalSizeDist()`](https://epiforesite.github.io/multigroup-vaccine/reference/getFinalSizeDist.md),
  and
  [`getSizeAtTime()`](https://epiforesite.github.io/multigroup-vaccine/reference/getSizeAtTime.md).

- Interactive Shiny application via
  [`run_my_app()`](https://epiforesite.github.io/multigroup-vaccine/reference/run_my_app.md)
  for exploring vaccine scenarios and visualizing effects of
  differential vaccination rates across population groups.

- U.S. Census data integration:
  [`getCensusData()`](https://epiforesite.github.io/multigroup-vaccine/reference/getCensusData.md)
  downloads and processes Census Bureau population estimates by age and
  county, with support for age-structured populations, sex
  disaggregation, and built-in caching. Helper functions include
  [`getCensusDataPath()`](https://epiforesite.github.io/multigroup-vaccine/reference/getCensusDataPath.md),
  [`getStateFIPS()`](https://epiforesite.github.io/multigroup-vaccine/reference/getStateFIPS.md),
  and
  [`listCounties()`](https://epiforesite.github.io/multigroup-vaccine/reference/listCounties.md).

- Contact matrix functionality using POLYMOD contact survey data via the
  `socialmixr` package for realistic age-structured epidemic modeling.

- Example dataset `UtahAgeCountyPop` with 2024 population estimates by
  age group for all Utah counties.

### Vignettes

- Contact Matrix Examples
- Comparison to epiworld
- Measles Age-Structured Model
