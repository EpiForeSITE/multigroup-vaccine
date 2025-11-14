# Get Census Population Data by Age and County

Downloads and processes U.S. Census Bureau population estimates for a
specified state and county, organized by age groups. Supports
single-year age data with optional sex disaggregation.

## Usage

``` r
getCensusData(
  state_fips,
  county_name,
  year = 2024,
  age_groups = NULL,
  by_sex = FALSE,
  csv_path = NULL,
  cache_dir = NULL
)
```

## Arguments

- state_fips:

  Two-digit FIPS code for the state (e.g., "49" for Utah)

- county_name:

  Name of the county (e.g., "Salt Lake County")

- year:

  Census estimate year: 2020-2024 for July 1 estimates, or 2020.1 for
  April 1, 2020 base

- age_groups:

  Vector of age limits for grouping (e.g., c(0, 5, 18, 65)). Default
  NULL returns single-year ages 0-85+

- by_sex:

  Logical, if TRUE returns separate male/female groups

- csv_path:

  Optional path to a previously downloaded census CSV file. If provided,
  data will be read from this file instead of downloading. Use
  `cache_dir` for automatic caching.

- cache_dir:

  Optional directory path for caching downloaded census files. If
  provided, the function will check for an existing cached file and use
  it, or download and save a new one. Default is NULL (no caching). Use
  "." for current directory or specify a custom path like
  "~/census_cache"

## Value

A list containing:

- county:

  County name

- state:

  State name

- year:

  Census year

- total_pop:

  Total population

- age_pops:

  Vector of populations by age group

- age_labels:

  Labels for each age group

- sex_labels:

  If by_sex=TRUE, labels indicating sex

- data:

  Full filtered data frame

## Examples

``` r
# Use the included example data (recommended for package examples)
slc_data <- getCensusData(
  state_fips = "49", 
  county_name = "Salt Lake County",
  year = 2024,
  csv_path = getCensusDataPath()
)
#> Reading census data from: /home/runner/work/_temp/Library/multigroup.vaccine/extdata/cc-est2024-syasex-49.csv

# Get age groups without sex disaggregation
slc_grouped <- getCensusData(
  state_fips = "49",
  county_name = "Salt Lake County", 
  year = 2024,
  age_groups = c(0, 5, 18, 65),
  csv_path = getCensusDataPath()
)
#> Reading census data from: /home/runner/work/_temp/Library/multigroup.vaccine/extdata/cc-est2024-syasex-49.csv
#> Aggregating ages 0 to 4: sum = 72443
#> Aggregating ages 5 to 17: sum = 219984
#> Aggregating ages 18 to 64: sum = 771551

# Get age groups by sex
slc_by_sex <- getCensusData(
  state_fips = "49",
  county_name = "Salt Lake County",
  year = 2024, 
  age_groups = c(0, 5, 18, 65),
  by_sex = TRUE,
  csv_path = getCensusDataPath()
)
#> Reading census data from: /home/runner/work/_temp/Library/multigroup.vaccine/extdata/cc-est2024-syasex-49.csv
#> Aggregating ages 0 to 4: sum = 37449
#> Aggregating ages 5 to 17: sum = 112422
#> Aggregating ages 18 to 64: sum = 395422
#> Aggregating ages 0 to 4: sum = 34994
#> Aggregating ages 5 to 17: sum = 107562
#> Aggregating ages 18 to 64: sum = 376129

if (FALSE) { # \dontrun{
# Download from web (requires internet)
slc_web <- getCensusData(
  state_fips = "49",
  county_name = "Salt Lake County",
  year = 2024
)

# Use caching to avoid repeated downloads
slc_cached <- getCensusData(
  state_fips = "49",
  county_name = "Salt Lake County",
  year = 2024,
  cache_dir = "~/census_cache"
)
} # }
```
