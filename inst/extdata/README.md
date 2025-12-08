# Example Census and City Data

This directory contains example U.S. Census Bureau population estimate data files included with the package.

## Files

### County-Level Data

- `cc-est2024-syasex-49.csv` - Utah (FIPS code 49) county-level population estimates by single-year age and sex, 2020-2024

### City-Level Data

- `hildale_ut_2023.csv` - Hildale city, Utah population estimates by 5-year age groups from ACS 5-year estimates (2019-2023)
- `colorado_city_az_2023.csv` - Colorado City city, Arizona population estimates by 5-year age groups from ACS 5-year estimates (2019-2023)

## Source

### County Data

Data downloaded from the U.S. Census Bureau Population Estimates Program:
https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/

### City Data

Data downloaded from the U.S. Census Bureau American Community Survey (ACS) 5-Year Estimates:
- Table S0101: Age and Sex
- 2019-2023 ACS 5-Year Estimates
- https://data.census.gov/

## Usage

### County Data

Access county-level data in your code using:

```r
library(multigroup.vaccine)

# Get the path to the example data file
utah_csv <- getCensusDataPath()

# Use it with getCensusData
slc_data <- getCensusData(
  state_fips = "49",
  county_name = "Salt Lake County",
  year = 2024,
  csv_path = getCensusDataPath()
)
```

### City Data

Access city-level data in your code using:

```r
library(multigroup.vaccine)

# Load Hildale city data
hildale_data <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
)

# Load Colorado City data
colorado_city_data <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = system.file("extdata", "colorado_city_az_2023.csv", package = "multigroup.vaccine")
)

# Load with custom age groups
hildale_custom <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"),
  age_groups = c(0, 5, 18, 65)
)
```

## Purpose

These files are included to:
1. Enable package examples and vignettes to run without internet access
2. Support `R CMD check` and `pkgdown` building processes
3. Allow offline testing and development
4. Provide working examples for users
5. Demonstrate real-world outbreak modeling scenarios in border communities

## Data Format

### County Data Format

The county CSV file contains the following columns:
- `SUMLEV` - Summary level (50 = county)
- `STATE` - State FIPS code
- `COUNTY` - County FIPS code
- `STNAME` - State name
- `CTYNAME` - County name
- `YEAR` - Estimate year code (1 = April 1, 2020 base; 2 = 2020; 3 = 2021; etc.)
- `AGE` - Single year of age (0-85+)
- `TOT_POP` - Total population
- `TOT_MALE` - Male population
- `TOT_FEMALE` - Female population

### City Data Format

The city CSV files contain ACS 5-year estimates with the following key columns:
- `GEO_ID` - Geographic identifier
- `NAME` - Geographic area name (e.g., "Hildale city, Utah")
- `S0101_C01_001E` - Total population
- `S0101_C01_002E` through `S0101_C01_019E` - Population by 5-year age groups:
  - Under 5 years
  - 5 to 9 years
  - 10 to 14 years
  - 15 to 19 years
  - 20 to 24 years
  - 25 to 29 years
  - 30 to 34 years
  - 35 to 39 years
  - 40 to 44 years
  - 45 to 49 years
  - 50 to 54 years
  - 55 to 59 years
  - 60 to 64 years
  - 65 to 69 years
  - 70 to 74 years
  - 75 to 79 years
  - 80 to 84 years
  - 85 years and over

See the metadata files (`*_metadata.csv`) for complete column descriptions.

## Updating

### County Data

To update county data with newer estimates:

```r
# Download the latest file (example for Utah)
url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/cc-est2024-syasex-49.csv"
download.file(url, "inst/extdata/cc-est2024-syasex-49.csv")
```

### City Data

To update city data with newer ACS estimates:

1. Visit https://data.census.gov/
2. Search for Table S0101 (Age and Sex)
3. Select the desired geography (place/city)
4. Download the latest 5-Year ACS estimates
5. Save to `inst/extdata/` with appropriate naming

Example for Hildale:
```r
# After downloading from data.census.gov
# Save as inst/extdata/hildale_ut_2023.csv
```

Then rebuild the package documentation with `devtools::document()`.
