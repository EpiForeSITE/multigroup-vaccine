# Getting Started Example

This vignette walks through a first example of setting up a multi-group
epidemic model and calculating useful quantities for analysis using
functions in this R package. After installing the package (see
instructions in README), load it:

``` r
library(multigroup.vaccine)
```

In our example model, we consider a population of size 10,000
individuals and with the following parameters:

- **Group population sizes**: two sub-populations, one with size
  80,000 (A) and the other with size 20,000 (B)

``` r
popsize <- c(80000, 20000)
```

- **Group-to-group contact rates**: to model an outbreak spreading among
  this population, we require quantification of contact among and
  between members of each group. We ultimately need to create the square
  matrix `contactmatrix` that describes the relative amount of contact
  that members of one group (row) has with each other group (column).
  The contact matrix could be quantified directly, but we recommend
  using one of the package functions to create it.

In this example we use a model for “proportionate contacts with
preferential mixing”, making use of our
[`contactMatrixPropPref()`](https://epiforesite.github.io/multigroup-vaccine/reference/contactMatrixPropPref.md)
function, which requires the following components. This contact model
can allows for different overall contact rates of members of each group.
Here we assume the relative contact rates are 1 and 1.7 for groups A and
B. This means that an individual in Group B makes 1.7 contacts for every
1 made by an individual in group A.

``` r
relcontact <- c(1, 1.7)
```

This contact model also can also assume preferential mixing within one’s
own group. We assume that the fraction of contacts that are exclusively
within-group is 0.2 for group A, and 0.5 for group B. For group A, this
means that 20% of their contacts are exclusively with other members of
group A, and the remaining 80% of contacts are split between both groups
A and B at rates proportional to the population sizes and overall
contact rates of each group. The latter element ensures that the overall
number of A-to-B and B-to-A contacts are equal, for contact symmetry.

``` r
incontact <- c(0.2, 0.5)
```

With the above elements, we calculate the contact matrix as follows

``` r
contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
```

- **Relative susceptibility to infection**. Now we are getting into
  modeling transmission of particular disease within the population
  described above. Not every contact between an infectious and a
  susceptible individual necessarily leads to a transmission. The two
  groups may differ in average susceptibility to infection per contact.
  With relative susceptibility 1 and 1.05, members of group B are 5%
  more susceptible to acquiring infection from an infectious contact
  than group A.

``` r
relsusc <- c(1, 1.05)
```

- **Relative transmissibility of infection**: The two groups may also
  differ in transmissibility per contact when infectious. With relative
  transmissibility 1 and 1.01, infectious members of group B are 1% more
  likely transmit infection to a susceptible contact compared to
  infectious members of group A.

``` r
reltransm <- c(1, 1.01)
```

- **Overall transmissibility of disease**. All the components above are
  enough to describe the *relative* transmission rates from one group to
  another, but we still need an absolute measure of how transmissible
  the disease is. This is often quantified by a basic reproduction
  number ($R_{0}$), defined as the average number of transmissions from
  a typical infectious individual if the rest of the population is
  suceptible. Here we set $R_{0}$ to 1.75.

``` r
R0 <- 1.75
```

- **Initial conditions and vaccination**: we assume no one is immune due
  to prior infection (compartment R), and one individual from group B is
  an initial infectious case (compartment I). We also assume that 30% of
  group A and 20% of group B are initially immune due to vaccination
  (compartment V).

``` r
initR <- c(0, 0)
initI <- c(0, 1)
initV <- c(0.3, 0.2) * popsize
```

- **Final outbreak size (ODE method)**: The
  [`finalsize()`](https://epiforesite.github.io/multigroup-vaccine/reference/finalsize.md)
  function computes the final number of infected people in each group at
  the end of the outbreak, by default using a deterministic ordinary
  differential equation (ODE) model and numerically solving the
  equations.

``` r
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
#> [1] 14139.571  8749.608
```

Over one third of the infected individuals are from population B,
despite the fact that they comprise only one fifth of the population.

- **Final outbreak size (analytic method)**: We also provide a method to
  solve an analytic equation for the final outbreak size, which avoids
  the need to numerically solve for the differential equation
  trajectory:

``` r
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")
#> [1] 14139.570  8749.609
```

While the analytic method might seem preferable, it is not necessarily
faster or more stable than the ODE numerical solution method, as the
analytic method still involves numerical estimation methods required to
solve the transcendental equations. We recommend using the default ODE
method, especially for models with a large number of groups.

- **Final outbreak size (stochastic method)**: We also provide a method
  to simulate stochastic (random) outbreaks until no infectious
  individuals remain, producing a distribution of final outbreak sizes.
  We can specify the numbers of simulations to run with the `nsims`
  argument, which defaults to 1 if unspecified.

``` r
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "stochastic",
          nsims = 10)
#>        [,1] [,2]
#>  [1,]     0    1
#>  [2,]     0    4
#>  [3,]     5    1
#>  [4,]     0    1
#>  [5,]     0    1
#>  [6,]     2    2
#>  [7,]     0    4
#>  [8,] 13457 8518
#>  [9,]     0    1
#> [10,]     0    2
```

Each row of the output has the results of one of the stochastic
simulations for the final outbreak size of each group (including the
initial one case in group B). We see that some simulations end after no
or a small number of transmissions due to random luck, while others grow
to a size close to the final size result from the deterministic results
above.

- **Final outbreak size (hybrid method)**. The simulations for the
  stochastic method can be slow when the simulated outbreak grows to a
  large size. When $R_{0} > 1$, we typically see the “bimodal”
  distribution of outcomes in stochastic simulations in which one set of
  simulated outbreaks have small final size while another set “escape”
  to a size that is quite close to the size predicted by the
  deterministic ODE solution. We created a “hybrid” simulation method
  that starts by simulating the outbreak stochastically as in the
  stochastic method. If the simulation reaches a state at which it is
  extremely unlikely to end in the next transmission generation, the
  simulation is halted and it is assumed that the final size will be the
  result from the ODE method.

``` r
finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "hybrid",
          nsims = 10)
#>        [,1] [,2]
#>  [1,]     3    1
#>  [2,]     1    1
#>  [3,]     3    5
#>  [4,]     0    1
#>  [5,] 14140 8750
#>  [6,]     1    1
#>  [7,]     0    1
#>  [8,]     5    4
#>  [9,]     0    1
#> [10,]     0    1
```
