# Example Census Data

This directory contains example U.S. Census Bureau population estimate data files included with the package.

## Files

- `cc-est2024-syasex-49.csv` - Utah (FIPS code 49) county-level population estimates by single-year age and sex, 2020-2024

## Source

Data downloaded from the U.S. Census Bureau Population Estimates Program:
https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/

## Usage

Access this file in your code using:

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
