# Run Model in the console

``` r
library(multigroup.vaccine)
```

Consider a population with the following parameters:

- Two sub-populations, one with size 80000 (A) and the other with size
  20000 (B)

- At time 0, vaccinate 30% of A and 20% of B

- Set the reproductive number 1.75

- Recovery rate of 1/7 creates a time to symptom resolution of 1 week.

- Relative contact rates are 1 and 1.7. This is the overall contact
  rates of groups A and B relative to each other. This means that an
  individual in Group B makes 1.7 contacts for every 1 made by an
  individual in group A.

- Contact within group is set to 0.2 for A, 0.5 for B. This is the
  fraction of all contacts that are A-\>A, or B-\>B respectively.

- Relative susceptibility is the susceptibility to infection per contact
  of individuals in each group relative to each other. With relative
  susceptibility = (1, 1), they are equally susceptible.

``` r
multigroup.vaccine::getFinalSize(vacTime = 0,
  vacPortion = c(0.3, 0.2),
  popSize = c(80000, 20000),
  R0 = 1.75,
  recoveryRate = 1 / 7,
  relContact = c(1, 1.7),
  contactWithinGroup = c(0.2, 0.5),
  relSusc = c(1, 1))
#> [1] 15145.987  8710.351
```

    [1] 15145.987  8710.351

More than half as many individuals in population B are infected at the
end of the simulation, despite the fact that they are outnumbered 4 to 1
by population A.
