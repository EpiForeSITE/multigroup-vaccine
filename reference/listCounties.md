# List available counties for a state

List available counties for a state

## Usage

``` r
listCounties(state_fips, year = 2024, csv_path = NULL, cache_dir = NULL)
```

## Arguments

- state_fips:

  Two-digit FIPS code for the state

- year:

  Census year (2020-2024), default 2024

- csv_path:

  Optional path to a previously downloaded census CSV file

- cache_dir:

  Optional directory path for caching downloaded census files

## Value

Character vector of county names

## Examples

``` r
# Use the included example data
utah_counties <- listCounties(
  state_fips = "49", 
  year = 2024,
  csv_path = getCensusDataPath()
)
#> Reading census data from: /home/runner/work/_temp/Library/multigroup.vaccine/extdata/cc-est2024-syasex-49.csv

if (FALSE) { # \dontrun{
# Download from web (requires internet)
utah_counties_web <- listCounties(state_fips = "49", year = 2024)

# With caching
utah_counties_cached <- listCounties(state_fips = "49", cache_dir = "~/census_cache")
} # }
```
