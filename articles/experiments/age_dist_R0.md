# Age distribution effect on R0

This vignette shows the effects of the age distribution of the Short
Creek community on the basic reproduction number $R_{0}$, compared to
other populations with different age distributions.

Warning: The data and calculations in this vignette are for
demonstration purposes only and do not reflect real-world conditions
accurately. The assumptions may not be accurate and may not reflect true
risk of measles outbreaks in these communities.

``` r
library(multigroup.vaccine)
library(socialmixr)
```

## Age groups

``` r
agelims <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)
```

## Getting city population data for Short Creek community

``` r
# Load city data files
hildale_path <- system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
colorado_city_path <- system.file("extdata", "colorado_city_az_2023.csv", package = "multigroup.vaccine")
centennial_park_path <- system.file("extdata", "centennial_park_az_2023.csv", package = "multigroup.vaccine")

hildale <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = hildale_path,
  age_groups = agelims
)

colorado_city <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = colorado_city_path,
  age_groups = agelims
)

centennial_park <- getCityData(
  city_name = "Centennial Park CDP, Arizona",
  csv_path = centennial_park_path,
  age_groups = agelims
)

agepops <- round(hildale$age_pops + colorado_city$age_pops + centennial_park$age_pops)
```

## Getting data from Washington County, Utah (where Hildale is located)

``` r
utah_fips <- getStateFIPS("Utah")
census_csv <- getCensusDataPath()
county <- "Washington County"

county_data <- getCensusData(
  state_fips = utah_fips,
  county_name = county,
  year = 2024,
  age_groups = agelims,
  csv_path = census_csv
)

county_pops <- county_data$age_pops
```

## Getting Utah State and national data:

``` r
state_ageprop <- c(0.0143, 0.0572, 0.1119, 0.0330, 0.0658, 0.1164, 0.2844, 0.2360, 0.0840)
state_agepops <- 3503613 * state_ageprop / sum(state_ageprop)

us_ageprop <- c(0.0133, 0.0517, 0.0825, 0.0335, 0.0670, 0.0900, 0.270, 0.304, 0.086)
us_agepops <- 340100000 * us_ageprop / sum(us_ageprop)
```

## School data

``` r
schoolpops <- c(250, 350, 190, 86, 150, 84, 114, 108, 205)
schoolagegroups <- c(3, 3, 3, 4, 4, 4, 5, 5, 5)
```

## Create contact matrix for Short Creek

``` r
#Readjust the school populations to match the age data:
for(a in unique(schoolagegroups)){
  inds <- which(schoolagegroups == a)
  schoolpops[inds] <- round(agepops[a] * schoolpops[inds] / sum(schoolpops[inds]))
}
cm <- contactMatrixAgeSchool(agelims, agepops, schoolagegroups, schoolpops, schportion = 0.7)
grouppops <- c(agepops[1:(min(schoolagegroups)-1)],
               schoolpops,
               agepops[(max(schoolagegroups)+1):length(agepops)])
```

## Create contact matrices for other populations

``` r
mijpolymod <- contactMatrixPolymod(agelims)
mijwashingtoncounty <- contactMatrixPolymod(agelims, county_pops)
mijutahstate <- contactMatrixPolymod(agelims, state_agepops)
mijusa <- contactMatrixPolymod(agelims, us_agepops)
```

## Calculate $R_{0}$ adjustment factors

``` r
eigpolymod <- eigen(mijpolymod)$values[1]
R0factorShortCreek <- eigen(cm)$values[1] / eigpolymod
R0factorWashingtonCounty <- eigen(mijwashingtoncounty)$values[1] / eigpolymod
R0factorUtahState <- eigen(mijutahstate)$values[1] / eigpolymod
R0factorUSA <- eigen(mijusa)$values[1] / eigpolymod

R0vals <- 6:12

R0local <- R0vals * R0factorShortCreek
R0county <- R0vals * R0factorWashingtonCounty
R0state <- R0vals * R0factorUtahState
R0national <- R0vals * R0factorUSA

knitr::kable(data.frame(R0Polymod = R0vals,
                        R0USA = round(R0national, 1),
                        R0Utah = round(R0state, 1),
                        R0County = round(R0county, 1),
                        R0ShortCreek = round(R0local, 1)),
             row.names = FALSE, format = "markdown")
```

| R0Polymod | R0USA | R0Utah | R0County | R0ShortCreek |
|----------:|------:|-------:|---------:|-------------:|
|         6 |   7.1 |    7.4 |      6.5 |         11.5 |
|         7 |   8.3 |    8.6 |      7.6 |         13.4 |
|         8 |   9.5 |    9.8 |      8.7 |         15.3 |
|         9 |  10.6 |   11.1 |      9.8 |         17.2 |
|        10 |  11.8 |   12.3 |     10.9 |         19.2 |
|        11 |  13.0 |   13.5 |     12.0 |         21.1 |
|        12 |  14.2 |   14.7 |     13.1 |         23.0 |
