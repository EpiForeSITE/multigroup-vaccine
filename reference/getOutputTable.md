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
