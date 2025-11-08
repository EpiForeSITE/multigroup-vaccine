# Comparison to epiworld

``` r
library(multigroup.vaccine)
library(epiworldR)
#> Thank you for using epiworldR! Please consider citing it in your work.
#> You can find the citation information by running
#>   citation("epiworldR")
```

``` r
pops <- c(60, 100, 500)
initI <- c(1, 0, 0)
initV <- c(0, 0, 0)
initR <- c(0, 0, 0)
R0 <- 1.5
meaninf <- 7
incontact <- c(0.8, 0.8, 0.8)
f <- (1 - incontact) * pops
cmat <- (diag(incontact) + outer((1 - incontact), f / sum(f)))

betaij <- transmissionRates(
  R0 = R0,
  meaninf = meaninf,
  reltransm = cmat
)

ode_size <- multigroup.vaccine::getFinalSizeODE(
  transmrates = betaij,
  recoveryrate = 1 / meaninf,
  popsize = pops,
  initR = initR,
  initI = initI,
  initV = initV
)

fsODE <- sum(ode_size$totalSize)
```

``` r
numsims <- 1000
size_dist <- getFinalSizeDist(
  n = numsims,
  transmrates = betaij,
  recoveryrate = 1 / meaninf,
  popsize = pops,
  initR = initR,
  initV = initV,
  initI = initI)

fs1 <- rowSums(size_dist)
```

``` r
abm_model <- ModelSEIRMixing(
  name = "abc",
  n = sum(pops),
  prevalence = 1 / sum(pops),
  contact_rate = R0 * (1 / meaninf) / .1,
  recovery_rate = 1 / meaninf,
  contact_matrix = cmat,
  transmission_rate = .1,
  incubation_days = 0
)

# Start off creating three entities.
# Individuals will be distribured randomly between the three.
e1 <- entity("Population 1", pops[1], as_proportion = FALSE)
e2 <- entity("Population 2", pops[2], as_proportion = FALSE)
e3 <- entity("Population 3", pops[3], as_proportion = FALSE)

grp <- rep(seq_along(pops), pops)
set_distribution_entity(
  entity = e1,
  distfun = distribute_entity_to_set(0:(pops[1] - 1))
)
set_distribution_entity(
  entity = e2,
  distfun = distribute_entity_to_set(pops[1]:(pops[2] - 1))
)
set_distribution_entity(
  entity = e3,
  distfun = distribute_entity_to_set(pops[2]:(sum(pops) - 1))
)

abm_model |>
  add_entity(e1) |>
  add_entity(e2) |>
  add_entity(e3)

set_distribution_virus(
  virus = get_virus(abm_model, 0),
  distfun = distribute_virus_randomly(1, FALSE, agents_ids = 0L)
)

# Creating the saver
saver <- make_saver("total_hist", "reproductive")

# Running multiple simulations
ndays <- 400
# nthr <- parallel::detectCores() - 1L
run_multiple(m = abm_model, ndays = ndays, nsims = numsims, saver = saver, nthreads = 1)
#> Starting multiple runs (1000) using 1 thread(s)
#> _________________________________________________________________________
#> _________________________________________________________________________
#> ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| done.
res <- run_multiple_get_results(abm_model, nthreads = 1)
total_hist <- res$total_hist
final_day <- total_hist[total_hist$date == ndays, ]
# fs2 <- final_day$counts[final_day$state == "Recovered"]

rr <- res$reproductive[res$reproductive$source >= 0, ]
rr$source_entity <- grp[rr$source + 1]
fs2 <- tabulate(rr$sim_num)
size_dist2 <- matrix(0, numsims, length(pops))
for (i in 1:numsims) {
  size_dist2[i, ] <- tabulate(rr$source_entity[rr$sim_num == i], length(pops))
}

getdiststats <- function(sd) {
  c(median = apply(sd, 2, median),
    mean = apply(sd, 2, mean),
    meanHigh = apply(sd, 2, function(x) mean(x[x > max(x) / 2])))
}

c(finalSizeODE = ode_size$totalSize)
#> finalSizeODE1 finalSizeODE2 finalSizeODE3 
#>      35.80713      58.32235     291.61177
cbind(finalSizeGillespie = getdiststats(size_dist), finalSizeEpiworld = getdiststats(size_dist2))
#>           finalSizeGillespie finalSizeEpiworld
#> median1              2.00000           3.00000
#> median2              0.00000           0.00000
#> median3              0.00000           0.00000
#> mean1               13.41700          13.65600
#> mean2               17.33400          17.30600
#> mean3               90.61200          92.72800
#> meanHigh1           39.83462          38.27547
#> meanHigh2           59.82400          57.09160
#> meanHigh3          287.99029         284.26667
```
