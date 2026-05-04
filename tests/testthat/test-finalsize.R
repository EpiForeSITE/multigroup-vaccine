library(multigroup.vaccine)

make_finalsize_test_inputs <- function() {
  popsize <- c(120, 80)

  list(
    popsize = popsize,
    R0 = 1.8,
    contactmatrix = contactMatrixPropPref(popsize, c(1, 1.2), c(0.4, 0.5)),
    relsusc = c(1, 0.9),
    reltransm = c(1, 1.1),
    initR = c(0, 0),
    initI = c(2, 1),
    initV = c(12, 8)
  )
}

test_that("deterministic final size calculations agree: 2 groups, vax at time 0", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  contactRatio <- 1.7
  suscRatio <- 1.1
  transmRatio <- 1.05
  incontact <- c(0.4, 0.4)

  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  reltransm <- c(1, transmRatio)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))

  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})

test_that("deterministic final size calculations agree: 2 groups, delayed vax", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  transmRatio <- 1.05
  incontact <- c(0.4, 0.4)
  vacTime <- 50

  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- c(0, 0)
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  reltransm <- c(1, transmRatio)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  transmmatrix <- transmissionRates(R0, 1 / recoveryRate, relsusc * t(reltransm * t(contactmatrix)))

  initsim <- getSizeAtTime(vacTime, transmmatrix, recoveryRate, popsize, initR, initI, initV)
  vacI <- initsim$activeSize
  vacR <- initsim$totalSize - vacI
  vacV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, vacR, vacI, vacV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, vacR, vacI, vacV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))
  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})

test_that("final size calculation works: 3 groups, vax at time 0", {
  vacPortion <- c(0.9, 0.8, 0.7)
  popsize <- c(80000, 1000, 500)
  R0 <- 15
  relcontact <- rep(1, 3)
  relsusc <- rep(1, 3)
  reltransm <- rep(1, 3)
  incontact <- rep(0.8, 3)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  initR <- c(0, 0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))

  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})

test_that("finalsize uses ODE method by default", {
  popsize <- c(1000, 500)
  R0 <- 2
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(100, 50)

  # Default method should be ODE
  result_default <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
  result_explicit <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  expect_equal(result_default, result_explicit)
})

test_that("finalsize throws error for invalid method", {
  popsize <- c(1000, 500)
  R0 <- 2
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(100, 50)

  expect_error(
    finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "invalid"),
    "Unknown method"
  )
})

test_that("finalsize handles single group correctly", {
  popsize <- 10000
  R0 <- 2.5
  contactmatrix <- matrix(1, 1, 1)
  relsusc <- 1
  reltransm <- 1
  initR <- 0
  initI <- 10
  initV <- 1000

  result_ode <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # Should work with single group
  expect_equal(length(result_ode), 1)
  expect_true(result_ode >= initI + initR)
  expect_true(result_ode <= popsize)
})

test_that("finalsize works with R0 < 1", {
  popsize <- c(5000, 5000)
  R0 <- 0.8  # Below epidemic threshold
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(10, 10)
  initV <- c(0, 0)

  result <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # With R0 < 1, outbreak should die out quickly
  expect_true(all(result < 0.05 * popsize))
})

test_that("finalsize works with high R0", {
  popsize <- c(5000, 5000)
  R0 <- 5  # High transmission
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(10, 10)
  initV <- c(0, 0)

  result <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # With high R0, large outbreak expected
  expect_true(all(result > 0.5 * popsize))
})

test_that("finalsize respects contact matrix structure", {
  popsize <- c(1000, 1000)
  R0 <- 2
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(10, 0)  # Only group 1 starts infected
  initV <- c(0, 0)

  # No contact between groups - group 2 should remain unaffected
  contactmatrix_isolated <- matrix(c(1, 0, 0, 1), 2, 2)
  result_isolated <- finalsize(popsize, R0, contactmatrix_isolated, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # Full mixing - both groups affected
  contactmatrix_mixed <- matrix(1, 2, 2)
  result_mixed <- finalsize(popsize, R0, contactmatrix_mixed, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # With isolation, group 2 should have much smaller outbreak
  expect_true(result_isolated[2] < result_mixed[2])
})

test_that("finalsize handles all population vaccinated", {
  popsize <- c(1000, 1000)
  R0 <- 3
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(10, 10)
  # Nearly everyone is vaccinated
  initV <- c(990, 990)

  result <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # Minimal outbreak due to lack of susceptibles
  expect_true(all(result <= initI + initR + 20))
})

test_that("finalsize with three groups and asymmetric contacts", {
  popsize <- c(1000, 500, 250)
  R0 <- 2.5
  # Asymmetric contact matrix
  contactmatrix <- matrix(c(
    1.0, 0.5, 0.2,
    0.5, 1.0, 0.3,
    0.2, 0.3, 1.0
  ), 3, 3, byrow = TRUE)
  relsusc <- c(1, 1, 1)
  reltransm <- c(1, 1, 1)
  initR <- c(0, 0, 0)
  initI <- c(10, 5, 2)
  initV <- c(100, 50, 25)

  result_ode <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  set.seed(12345)
  result_analytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  expect_equal(length(result_ode), 3)
  expect_equal(length(result_analytic), 3)
  # Both methods should give similar results
  expect_equal(result_ode, result_analytic, tolerance = 2)
})

test_that("finalsize returns vector for deterministic methods", {
  popsize <- c(1000, 500)
  R0 <- 2
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(100, 50)

  result_ode <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  result_analytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  # Deterministic methods should return vectors
  expect_true(is.numeric(result_ode))
  expect_true(is.numeric(result_analytic))
  expect_equal(length(result_ode), length(popsize))
  expect_equal(length(result_analytic), length(popsize))
})

test_that("finalsize handles zero initial infection in one group", {
  popsize <- c(1000, 1000)
  R0 <- 2.5
  contactmatrix <- matrix(1, 2, 2)
  relsusc <- c(1, 1)
  reltransm <- c(1, 1)
  initR <- c(0, 0)
  # Infection only in group 1
  initI <- c(10, 0)
  initV <- c(0, 0)

  result <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")

  # Both groups should be affected due to mixing
  expect_true(result[1] > initI[1])
  expect_true(result[2] > initI[2])
})

test_that("finalsize correctly scales with population size", {
  R0 <- 2
  contactmatrix <- matrix(1, 1, 1)
  relsusc <- 1
  reltransm <- 1
  initR <- 0
  initV <- 0

  # Small population
  result_small <- finalsize(1000, R0, contactmatrix, relsusc, reltransm, initR, 10, initV, method = "ODE")

  # Large population (10x)
  result_large <- finalsize(10000, R0, contactmatrix, relsusc, reltransm, initR, 100, initV, method = "ODE")

  # Attack rate should be similar (final size / population)
  attack_rate_small <- result_small / 1000
  attack_rate_large <- result_large / 10000

  expect_equal(attack_rate_small, attack_rate_large, tolerance = 0.05)
})

# what happens if the entire population is initially infected
test_that("getFinalSizeAnalytic with entire population initially infected", {
  transmrates <- matrix(0.5, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 999  # Entire population has already been infected, except for one susceptible individual, and one initial case
  initI <- 1
  initV <- 0

  result <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  )

  # Final size should equal initial recovered plus initial infected
  # what is happening to initV
  expect_equal(result, initR + 1)
})

test_that("finalsize stochastic simulations are reproducible across thread counts", {
  args <- make_finalsize_test_inputs()

  set.seed(12345)
  single_thread <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 1))
  )

  set.seed(12345)
  multi_thread <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 2))
  )

  expect_equal(single_thread, multi_thread)
  expect_equal(dim(multi_thread), c(6, length(args$popsize)))
})

test_that("finalsize stochastic leaves identical RNG progression across thread counts", {
  args <- make_finalsize_test_inputs()

  set.seed(777)
  do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 1))
  )
  next_single <- runif(5)

  set.seed(777)
  do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 2))
  )
  next_multi <- runif(5)

  expect_equal(next_single, next_multi)
})

test_that("finalsize stochastic seed argument is reproducible independent of global RNG", {
  args <- make_finalsize_test_inputs()

  set.seed(1001)
  from_seed_a <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 1, seed = 4321))
  )

  set.seed(9009)
  from_seed_b <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 6, nthreads = 2, seed = 4321))
  )

  expect_equal(from_seed_a, from_seed_b)
})

test_that("finalsize hybrid seed argument is reproducible independent of global RNG", {
  args <- make_finalsize_test_inputs()

  set.seed(101)
  from_seed_a <- do.call(
    finalsize,
    c(args, list(method = "hybrid", nsims = 6, seed = 7654))
  )

  set.seed(202)
  from_seed_b <- do.call(
    finalsize,
    c(args, list(method = "hybrid", nsims = 6, seed = 7654))
  )

  expect_equal(from_seed_a, from_seed_b)
})

test_that("finalsize hybrid simulations continue to use getFinalSizeDistEscape", {
  args <- make_finalsize_test_inputs()

  set.seed(54321)
  from_finalsize <- do.call(
    finalsize,
    c(args, list(method = "hybrid", nsims = 5, nthreads = 2))
  )

  set.seed(54321)
  from_helper <- getFinalSizeDistEscape(
    n = 5,
    transmrates = transmissionRates(
      args$R0,
      1,
      args$relsusc * t(args$reltransm * t(args$contactmatrix))
    ),
    recoveryrate = 1,
    popsize = args$popsize,
    initR = args$initR,
    initI = args$initI,
    initV = args$initV
  )

  expect_equal(from_finalsize, from_helper)
  expect_equal(dim(from_finalsize), c(5, length(args$popsize)))
})

test_that("finalsize accepts auto-detect sentinel values for nthreads", {
  args <- make_finalsize_test_inputs()

  testthat::local_mocked_bindings(
    detectCores = function(...) 1L,
    .package = "parallel"
  )

  set.seed(24680)
  auto_zero <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 4, nthreads = 0))
  )

  set.seed(24680)
  auto_minus_one <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 4, nthreads = -1))
  )

  expect_equal(auto_zero, auto_minus_one)
  expect_equal(dim(auto_zero), c(4, length(args$popsize)))
})

test_that("finalsize validates nsims, nthreads, and cluster inputs", {
  args <- make_finalsize_test_inputs()

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 0))),
    "nsims must be a single positive integer"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, nthreads = 2.5))),
    "nthreads must be a positive integer, or 0/-1 to auto-detect available cores"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, nthreads = -5))),
    "nthreads must be a positive integer, or 0/-1 to auto-detect available cores"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, nthreads = NA_real_))),
    "nthreads must be a single, non-NA numeric value"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, cluster = 1))),
    "cluster must inherit from 'cluster'"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, seed = 1.5))),
    "seed must be NULL or a single finite integer value"
  )

  expect_error(
    do.call(finalsize, c(args, list(method = "stochastic", nsims = 4, seed = NA_real_))),
    "seed must be NULL or a single finite integer value"
  )
})

test_that("finalsize falls back to one thread when core detection is unavailable", {
  args <- make_finalsize_test_inputs()

  testthat::local_mocked_bindings(
    detectCores = function(...) NA_integer_,
    .package = "parallel"
  )

  set.seed(11223)
  result <- do.call(
    finalsize,
    c(args, list(method = "stochastic", nsims = 3, nthreads = 0))
  )

  expect_equal(dim(result), c(3, length(args$popsize)))
})
