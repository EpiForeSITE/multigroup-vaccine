# List available counties for a state

List available counties for a state

## Usage

``` r
listCounties(
  state_fips,
  year = 2024,
  csv_path = NULL,
  cache_dir = NULL,
  verbose = FALSE
)
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

- verbose:

  Logical, if TRUE prints messages about data loading. Default is FALSE.

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

if (FALSE) { # \dontrun{
# Download from web (requires internet)
utah_counties_web <- listCounties(state_fips = "49", year = 2024)

# With caching
utah_counties_cached <- listCounties(state_fips = "49", cache_dir = "~/census_cache")
} # }
```
