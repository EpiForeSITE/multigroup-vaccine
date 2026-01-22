# Age distribution effect on R0

This vignette shows the effects of the age distribution of the Short
Creek community on the basic reproduction number $R_{0}$, compared to
other populations with different age distributions.

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
#> Aggregating ages 0 to 0: sum = 11.4
#> Aggregating ages 1 to 4: sum = 45.6
#> Aggregating ages 5 to 11: sum = 182.4
#> Aggregating ages 12 to 13: sum = 72.4
#> Aggregating ages 14 to 17: sum = 130.4
#> Aggregating ages 18 to 24: sum = 196.8
#> Aggregating ages 25 to 44: sum = 352
#> Aggregating ages 45 to 69: sum = 265

colorado_city <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = colorado_city_path,
  age_groups = agelims
)
#> Aggregating ages 0 to 0: sum = 25
#> Aggregating ages 1 to 4: sum = 100
#> Aggregating ages 5 to 11: sum = 387
#> Aggregating ages 12 to 13: sum = 174
#> Aggregating ages 14 to 17: sum = 373.8
#> Aggregating ages 18 to 24: sum = 480.2
#> Aggregating ages 25 to 44: sum = 532
#> Aggregating ages 45 to 69: sum = 508

centennial_park <- getCityData(
  city_name = "Centennial Park CDP, Arizona",
  csv_path = centennial_park_path,
  age_groups = agelims
)
#> Aggregating ages 0 to 0: sum = 76.2
#> Aggregating ages 1 to 4: sum = 304.8
#> Aggregating ages 5 to 11: sum = 318
#> Aggregating ages 12 to 13: sum = 72
#> Aggregating ages 14 to 17: sum = 163.2
#> Aggregating ages 18 to 24: sum = 214.8
#> Aggregating ages 25 to 44: sum = 395
#> Aggregating ages 45 to 69: sum = 189

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
#> Reading census data from: /home/runner/work/_temp/Library/multigroup.vaccine/extdata/cc-est2024-syasex-49.csv
#> Aggregating ages 0 to 0: sum = 2263
#> Aggregating ages 1 to 4: sum = 9687
#> Aggregating ages 5 to 11: sum = 18808
#> Aggregating ages 12 to 13: sum = 5736
#> Aggregating ages 14 to 17: sum = 12710
#> Aggregating ages 18 to 24: sum = 19948
#> Aggregating ages 25 to 44: sum = 49399
#> Aggregating ages 45 to 69: sum = 55271

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
