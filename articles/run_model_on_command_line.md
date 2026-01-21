# Two Group Final Outbreak Size Example

``` r
library(multigroup.vaccine)
```

Consider a population with the following parameters:

- Two sub-populations, one with size 80000 (A) and the other with size
  20000 (B)

``` r
popsize <- c(80000, 20000)
```

- Set the basic reproduction number ($R_{0}$) to 1.75

``` r
R0 <- 1.75
```

- For group-to-group contact rates, we use a model for proportionate
  contacts with preferential mixing, making use of our
  [`contactMatrixPropPref()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPropPref.md)
  function. This contact model allows for different overall contact
  rates of members of each group. Here we assume the relative contact
  rates are 1 and 1.7 for groups A and B. This means that an individual
  in Group B makes 1.7 contacts for every 1 made by an individual in
  group A.

``` r
relcontact <- c(1, 1.7)
```

- The contact model also assumes preferential mixing within one’s own
  group. We assume that the fraction of contacts that are exclusively
  within-group is 0.2 for group A, and 0.5 for group B. For group A,
  this means that 20% of their contacts are exclusively with other
  members of group A, and the remaining 80% of contacts are split
  between both groups A and B at rates proportional to the population
  sizes and overall contact rates of each group. The latter element
  ensures that the overall number of A-to-B and B-to-A contacts are
  equal, for contact symmetry.

``` r
incontact <- c(0.2, 0.5)
```

- With the above elements, we calculate the contact matrix as follows

``` r
contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
```

- Not every contact between an infectious and a susceptible individual
  necessarily leads to a transmission. The two groups may differ in
  average susceptibility to infection per contact. With relative
  susceptibility 1 and 1.05, members of group B are 5% more susceptible
  to acquiring infection from an infectious contact than group A.

``` r
relsusc <- c(1, 1.05)
```

- The two groups may also differ in transmissibility per contact when
  infectious. With relative transmissibility 1 and 1.01, infectious
  members of group B are 1% more likely transmit infection to a
  susceptible contact compared to infectious members of group A.

``` r
reltransm <- c(1, 1.01)
```

- For initial conditions, we assume no one is immune due to prior
  infection (compartment R), and one individual from group A is an
  initial infectious case (compartment I). We also assume that 30% of
  group A and 20% of group B are initially immune due to vaccination
  (compartment V).

``` r
initR <- c(0, 0)
initI <- c(1, 0)
initV <- c(0.3, 0.2) * popsize
```

- The
  [`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md)
  function computes the final number of infected people in each group at
  the end of the outbreak, by default using a deterministic differential
  equation model and numerically solving the equations.

``` r
fs <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
fs
#> [1] 14140.46  8748.82
```

Over one third of the infected individuals are from population B,
despite the fact that they comprise only one fifth of the population.
