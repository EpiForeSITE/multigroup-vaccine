# Example Census Data

This directory contains example U.S. Census Bureau population estimate data files and city-specific American Community Survey (ACS) data included with the package.

### County-Level Census Data

- `cc-est2024-syasex-49.csv` - Utah (FIPS code 49) county-level population estimates by single-year age and sex, 2020-2024

### City-Level ACS Data

- `hildale_ut_2023.csv` - Hildale city, Utah population by age from ACS 5-Year Estimates (2019-2023)
- `hildale_ut_2023_metadata.csv` - Metadata for Hildale ACS data (variable descriptions)
- `colorado_city_az_2023.csv` - Colorado City town, Arizona population by age from ACS 5-Year Estimates (2019-2023)
- `colorado_city_az_2023_metadata.csv` - Metadata for Colorado City ACS data (variable descriptions)
- `centennial_park_az_2023.csv` - Centennial Park, AZ population by age from ACS 5-Year Estimates (2019-2023)

## Source

### County-Level Data

Data downloaded from the U.S. Census Bureau Population Estimates Program:
https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/

### City-Level Data

Data downloaded from the U.S. Census Bureau American Community Survey (ACS) 5-Year Estimates via data.census.gov:
- **Hildale, UT**: Table S0101 (Age and Sex), 2019-2023 ACS 5-Year Estimates
- **Colorado City, AZ**: Table S0101 (Age and Sex), 2019-2023 ACS 5-Year Estimates
- **Centennial Park, AZ**: Table S0101 (Age and Sex), 2019-2023 ACS 5-Year Estimates

## Usage

### County-Level Census Data

Access county data in your code using:

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

### City-Level ACS Data

Access city data using:

```r
library(multigroup.vaccine)

# Load Hildale data with default 5-year age groups
hildale_data <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv", 
                         package = "multigroup.vaccine")
)

# Load Colorado City data
colorado_city_data <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = system.file("extdata", "colorado_city_az_2023.csv",
                         package = "multigroup.vaccine")
)

# Load with custom age groups
hildale_custom <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = system.file("extdata", "hildale_ut_2023.csv",
                         package = "multigroup.vaccine"),
  age_groups = c(0, 5, 18, 65)
)
```

## Purpose

This file is included to:
1. Enable package examples to run without internet access
2. Support `R CMD check` and `pkgdown` building processes
3. Allow offline testing and development
4. Provide a working example for users

## Data Format

The CSV file contains the following columns:
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

## Updating

To update this file with newer data:

```r
# Download the latest file
url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/cc-est2024-syasex-49.csv"
download.file(url, "inst/extdata/cc-est2024-syasex-49.csv")
```

Then rebuild the package documentation with `devtools::document()`.
