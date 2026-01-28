# Measles Age-Structured Model

``` r
library(multigroup.vaccine)
library(socialmixr)
```

This vignette demonstrates how to build and run an age-structured model
of transmission within a U.S. county. The example is an outbreak of
measles in Washington County, Utah.

First we define the age groups that we want use in our model. Here we
choose groupings for which we might have reason to assume different
levels of immunization against measles. We define the `age_limits`
vector using the lower limit (minimum age) of each group, starting with
0:

``` r
# under 1, 1-4, 5-11, 12-17, 18-24, 25-44, 45-69, 70 plus
age_limits <- c(0, 1, 5, 12, 18, 25, 45, 70)
```

Next we collect census data from Washington County, Utah, using our
custom age group choice:

``` r
# Get data for Washington County, Utah
washington_data <- getCensusData(
  state_fips = getStateFIPS("Utah"),
  county_name = "Washington County",
  year = 2024,
  age_groups = age_limits,
  csv_path = getCensusDataPath()
)
```

Now we specify immunity levels of our population age groups due to
vaccination. The first age group (under 1 year) has no immunity because
the first measles vaccine is not given until age one. Then we assume
rising immunity with age:

``` r
age_immunity <- c(0, 0.77, 0.83, 0.85, 0.87, 0.90, 0.92, 1)
```

Now we can begin defining the input arguments to our `finalsize`
function so that we can estimate the measles outbreak size in this
county after an introduction.

Initial population size of each state:

``` r
popsize <- washington_data$age_pops

initV <- round(age_immunity * popsize)  # initially immune cases 

initI <- rep(0, length(popsize))  # initial infectious cases
initI[6] <- 1                     # assume 1 initial case in the 6th age group (25-44)

initR <- rep(0, length(popsize))  # no recent prior measles outbreaks
```

Transmission matrix ingredients: contact matrix, relative susceptibility
and transmissibility, and the basic reproduction number ($R_{0}$). The
contact matrix uses Polymod contact survey data, adjusted for local
population distribution:

``` r
contactmatrix <- contactMatrixPolymod(age_limits, popsize)
relsusc <- rep(1, length(popsize))      # Assume no age differences in susceptibility
reltransm <- rep(1, length(popsize))    # or transmissibility per contact
R0 <- 10
```

Now we can estimate the final size of an outbreak using the defualt,
deterministic solution produced by the
[`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md)
function:

``` r
fs <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
round(sum(fs))
#> [1] 7573
```

Under the model assumptions and with $R_{0}$ = 10, there could be an
outbreak of more than 7,500 measles cases in this county.

Here’s how the outbreak size looks for each age group:

``` r
names(fs) <- washington_data$age_labels
round(fs)
#> under1   1to4  5to11 12to17 18to24 25to44 45to69 70plus 
#>    372    648   1673   1748    876   1414    843      0
```

Here’s an example using the “hybrid” method option in the
[`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md)
function, which runs stochastic simulations from the initial conditions
until the outbreak dies out or reaches an “escape” threshold, after
which the stochastic simulation is suspended and replaced with the
deterministic solution above.

``` r
fs_hybrid <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "hybrid", nsims = 30)
colnames(fs_hybrid) <- washington_data$age_labels
fs_hybrid
#>       under1 1to4 5to11 12to17 18to24 25to44 45to69 70plus
#>  [1,]      0    0     0      0      0      1      0      0
#>  [2,]      0    0     0      1      4      3      0      0
#>  [3,]      0    0     0      0      0      1      0      0
#>  [4,]      0    0     0      0      0      1      0      0
#>  [5,]      0    0     0      0      0      1      0      0
#>  [6,]      4    0     0      7      0      1      1      0
#>  [7,]      0    0     0      0      0      1      0      0
#>  [8,]    372  648  1673   1748    876   1414    843      0
#>  [9,]      0    0     0      0      0      1      0      0
#> [10,]      0    0     0      0      0      1      0      0
#> [11,]      0    0     0      0      0      1      0      0
#> [12,]      0    0     0      0      0      1      0      0
#> [13,]      0    0     0      0      0      1      0      0
#> [14,]      0    0     0      1      1      4      0      0
#> [15,]      1    0     0      0      0      1      1      0
#> [16,]    372  648  1673   1748    876   1414    843      0
#> [17,]      0    0     0      0      0      1      0      0
#> [18,]      1    2     2      0      0      4      0      0
#> [19,]      0    0     0      0      0      1      0      0
#> [20,]    372  648  1673   1748    876   1414    843      0
#> [21,]      4    2     5      1      3      8      2      0
#> [22,]      0    0     0      0      0      2      0      0
#> [23,]      0    2     1      0      0      1      0      0
#> [24,]      0    0     0      0      0      1      0      0
#> [25,]    372  648  1673   1748    876   1414    843      0
#> [26,]      0    0     0      0      0      2      0      0
#> [27,]    372  648  1673   1748    876   1414    843      0
#> [28,]      0    0     0      0      2      2      0      0
#> [29,]      0    0     0      0      0      1      0      0
#> [30,]      0    0     0      0      0      1      0      0
```

The results show that not every introduction of one infectious
individual (in the 25 to 44 age group) will lead to a large outbreak.
