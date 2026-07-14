# Get Census Data for All Counties in a State

Downloads and processes U.S. Census Bureau population estimates for all
counties in a specified state, organized by age groups. Returns a list
where each element contains the data for one county.

## Usage

``` r
getAllCountiesData(
  state_fips,
  year = 2025,
  age_groups = NULL,
  age_groups_by_county = NULL,
  by_sex = FALSE,
  csv_path = NULL,
  cache_dir = NULL,
  verbose = FALSE
)
```

## Arguments

- state_fips:

  Two-digit FIPS code for the state (e.g., "49" for Utah)

- year:

  Census estimate year: 2020-2025 for July 1 estimates, or 2020.1 for
  April 1, 2020 base

- age_groups:

  Vector of age limits for grouping (e.g., c(0, 5, 18, 65)). Default
  NULL returns single-year ages 0-85+. Ignored if `age_groups_by_county`
  is provided.

- age_groups_by_county:

  Optional named list where each element is a vector of age limits for a
  specific county. Names should match county names (with or without "
  County" suffix). When provided, county-specific age groups will be
  used, overriding the `age_groups` parameter. Example:
  `list("Salt Lake" = c(0, 5, 18, 65), "Utah" = c(0, 5, 11, 18, 65))`

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

- verbose:

  Logical, if TRUE prints messages about data loading and processing.
  Default is FALSE.

## Value

A named list where each element corresponds to one county. Each element
is a list containing the same structure as returned by
[`getCensusData()`](https://epiforesite.github.io/multigroup-vaccine/reference/getCensusData.md):

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
# Use the included example data for Utah
# \donttest{
utah_all <- getAllCountiesData(
  state_fips = "49",
  year = 2025,
  csv_path = getCensusDataPath()
)

# Access specific counties
utah_all[["Salt Lake County, Utah"]]
#> NULL
utah_all[["Utah County, Utah"]]
#> NULL

# Get with age groups
utah_grouped <- getAllCountiesData(
  state_fips = "49",
  year = 2025,
  age_groups = c(0, 18, 65),
  csv_path = getCensusDataPath()
)

# Get with county-specific age groups
county_ages <- list(
  "Salt Lake" = c(0, 5, 18, 65),
  "Utah" = c(0, 5, 11, 18, 65)
)
utah_custom <- getAllCountiesData(
  state_fips = "49",
  year = 2025,
  age_groups_by_county = county_ages,
  csv_path = getCensusDataPath()
)

# Download from web (requires internet)
utah_web <- getAllCountiesData(
  state_fips = "49",
  year = 2025
)
# }
```
