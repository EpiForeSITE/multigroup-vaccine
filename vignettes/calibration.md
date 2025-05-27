# Sensitivity Analysis


``` r
library(multigroup.vaccine)

pops <- c(60, 100, 500)
R0 <- 1.5
meaninf <- 7

cmat <- matrix(
  c(0.8, 0.1, 0.1,
    0.1, 0.8, 0.1,
    0.1, 0.1, 0.8
    ),
  nrow = 3, byrow = TRUE
)

betaij <- transmissionRates(
  R0 = R0,
  meaninf = meaninf,
  popsize = pops,
  contactmatrix = cmat,
  relcontact = c(1, 1, 1),
  relsusc = c(1, 1, 1)
)

ode_size <- multigroup.vaccine:::getFinalSizeSim(
  R0 = R0,
  recoveryRate = 1 / meaninf,
  popsize = pops,
  initR = rep(0, 3),
  initI = c(1, 0, 0),
  initV = rep(0, 3),
  contactmatrix = cmat,
  relcontact = c(1, 1, 1),
  relsusc = c(1, 1, 1)
  )

sum(ode_size$totalSize)
```

    [1] 386.7012

``` r
bet <- transmissionRates(R0, meaninf, pops, cmat, c(1, 1, 1), c(1, 1, 1))
size_dist <- multigroup.vaccine:::getFinalSizeDist(
  n = 500,
  popsize = pops,
  recoveryrate = 1 / meaninf,
  transmrates = bet,
  initI = c(1, 0, 0),
  initV = rep(0, 3)
)
fs1 <- rowSums(size_dist)
c(median = median(fs1), mean = mean(fs1), max = max(fs1))
```

     median    mean     max 
     28.000 175.298 470.000 

``` r
library(epiworldR)

abm_model <- ModelSEIRMixing(
  name = "abc",
  n = sum(pops),
  prevalence = 1/sum(pops),
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

abm_model |>
  add_entity(e1) |>
  add_entity(e2) |>
  add_entity(e3)

# Creating the saver
saver <- make_saver("total_hist", "reproductive")

# Running multiple simulations
set.seed(331)
ndays <- 400
run_multiple(m = abm_model, ndays = ndays, nsims = 500, saver = saver, nthreads = 1)
```

    Starting multiple runs (500) using 1 thread(s)
    _________________________________________________________________________
    _________________________________________________________________________
    ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| done.

``` r
res <- run_multiple_get_results(abm_model)
total_hist <- res$total_hist
final_day <- total_hist[total_hist$date == ndays, ]
fs2 <- final_day$counts[final_day$state == "Recovered"]
rbind(c(median = median(fs1), mean = mean(fs1), max = max(fs1)),
  c(median = median(fs2), mean = mean(fs2), max = max(fs2)))
```

         median    mean max
    [1,]     28 175.298 470
    [2,]      3 112.674 490
