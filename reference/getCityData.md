# Get City Population Data by Age

Reads and processes population data for specific cities from ACS 5-year
estimates, organized by age groups. The ACS data provides 5-year age
groupings (0-4, 5-9, etc.) which can be disaggregated into single-year
ages or aggregated into custom age groups.

## Usage

``` r
getCityData(
  city_name,
  csv_path,
  age_groups = c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85)
)
```

## Arguments

- city_name:

  Name of the city (e.g., "Hildale city, Utah")

- csv_path:

  Path to the city population CSV file

- age_groups:

  Vector of age limits for grouping. If NULL, returns single-year ages
  (disaggregated from 5-year ACS groups). Default uses 5-year intervals:
  c(0,5,10,...,85)

## Value

A list containing:

- city:

  City name

- year:

  Data year

- total_pop:

  Total population

- age_pops:

  Vector of populations by age group

- age_labels:

  Labels for each age group

- data:

  Full data frame

## Examples

``` r
# Load Hildale data with default 5-year age groups
hildale_data <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
)
#> Aggregating ages 0 to 4: sum = 57
#> Aggregating ages 5 to 9: sum = 110
#> Aggregating ages 10 to 14: sum = 181
#> Aggregating ages 15 to 19: sum = 157
#> Aggregating ages 20 to 24: sum = 134
#> Aggregating ages 25 to 29: sum = 128
#> Aggregating ages 30 to 34: sum = 55
#> Aggregating ages 35 to 39: sum = 110
#> Aggregating ages 40 to 44: sum = 59
#> Aggregating ages 45 to 49: sum = 105
#> Aggregating ages 50 to 54: sum = 64
#> Aggregating ages 55 to 59: sum = 32
#> Aggregating ages 60 to 64: sum = 29
#> Aggregating ages 65 to 69: sum = 35
#> Aggregating ages 70 to 74: sum = 0
#> Aggregating ages 75 to 79: sum = 27
#> Aggregating ages 80 to 84: sum = 18

# Load with single-year ages (disaggregated)
hildale_single <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"),
  age_groups = NULL
)

# Load with custom age groups
hildale_custom <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"),
  age_groups = c(0, 18, 65)
)
#> Aggregating ages 0 to 17: sum = 442.2
#> Aggregating ages 18 to 64: sum = 778.8
```
