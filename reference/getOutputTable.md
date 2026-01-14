# Generate Output Table for Vaccine Model Scenarios

This function generates a comprehensive output table showing R0 values,
vaccine effectiveness, and escape probabilities for different
vaccination scenarios in a multigroup population model.

## Usage

``` r
getOutputTable(agelims, agepops, agecovr, ageveff, initgrp)
```

## Arguments

- agelims:

  Vector of age group limits (lower bounds)

- agepops:

  Vector of population sizes for each age group

- agecovr:

  Vector of vaccination coverage rates for each age group

- ageveff:

  Vector of vaccine effectiveness rates for each age group

- initgrp:

  Index of the age group where the initial infection occurs

## Value

A matrix with columns for R0, R0local, Rv, pEscape, escapeInfTot, and
infection counts by age group

## Examples

``` r
# \donttest{
# Define age groups: 0-4, 5-17, 18-64, 65+
agelims <- c(0, 5, 18, 65)
agepops <- c(1000, 3000, 5000, 1500)

# Vaccination coverage: none for <5, 80% for school-age, 70% for adults, 90% for elderly
agecovr <- c(0, 0.8, 0.7, 0.9)

# Vaccine effectiveness: 0% for <5 (not vaccinated), 90% for others
ageveff <- c(0, 0.9, 0.9, 0.95)

# Initial infection in school-age group (index 2)
initgrp <- 2

# Generate output table
results <- getOutputTable(agelims, agepops, agecovr, ageveff, initgrp)
print(results)
#>       R0  R0local       Rv pEscape escapeInfTot under5 5to17 18to64 65+
#>  [1,] 10 15.04640 4.788559   0.828         3765    991   838   1779 157
#>  [2,] 11 16.55103 5.267415   0.837         3799    995   839   1801 165
#>  [3,] 12 18.05567 5.746271   0.861         3824    997   839   1815 172
#>  [4,] 13 19.56031 6.225127   0.869         3842    998   840   1826 178
#>  [5,] 14 21.06495 6.703983   0.869         3855    999   840   1833 184
#>  [6,] 15 22.56959 7.182839   0.890         3865    999   840   1838 188
#>  [7,] 16 24.07423 7.661695   0.883         3873   1000   840   1841 192
#>  [8,] 17 25.57887 8.140551   0.897         3879   1000   840   1844 195
#>  [9,] 18 27.08351 8.619407   0.901         3884   1000   840   1846 198
# }
```
