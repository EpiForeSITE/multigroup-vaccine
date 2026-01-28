test_that("getFinalSizeDistEscape returns correct dimensions", {
  transmrates <- matrix(0.2, 2, 2)
  recoveryrate <- 0.3
  popsize <- c(100, 150)
  initR <- c(0, 0)
  initI <- c(1, 0)
  initV <- c(10, 10)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should return n x g matrix
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), length(popsize))
  expect_true(is.matrix(result))
})

test_that("getFinalSizeDistEscape final sizes are bounded by population", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 500)
  initR <- c(0, 0)
  initI <- c(10, 5)
  initV <- c(50, 25)
  n <- 100
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Every simulation should have final size within bounds
  for (i in 1:n) {
    # Cannot exceed population
    expect_true(all(result[i, ] <= popsize))
    # Must be at least initial infected + recovered
    expect_true(all(result[i, ] >= initI + initR))
  }
})

test_that("getFinalSizeDistEscape is reproducible with set seed", {
  transmrates <- matrix(c(0.3, 0.1, 0.15, 0.25), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(50, 30)
  n <- 50
  
  set.seed(12345)
  result1 <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  set.seed(12345)
  result2 <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should be identical with same seed
  expect_equal(result1, result2)
})

test_that("getFinalSizeDistEscape shows stochastic variation", {
  transmrates <- matrix(0.35, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(2, 1)  # Lower initial infection for more stochastic phase
  initV <- c(50, 30)
  n <- 100
  
  set.seed(98765)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should have variation across simulations (not all identical)
  # Check that standard deviation is positive for at least one group
  expect_true(sd(result[, 1]) > 0 || sd(result[, 2]) > 0)
})

test_that("getFinalSizeDistEscape handles single group", {
  transmrates <- matrix(0.3, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  initV <- 100
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 1)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeDistEscape with R0 < 1 has small outbreaks", {
  # R0 = transmrate / recoveryrate = 0.15 / 0.2 = 0.75 < 1
  transmrates <- matrix(0.15, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  n <- 100
  
  set.seed(11111)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Average outbreak should be small (< 5% of population)
  mean_final_size <- mean(result)
  expect_true(mean_final_size < 0.05 * popsize)
})

test_that("getFinalSizeDistEscape with high R0 has large outbreaks", {
  # R0 = transmrate / recoveryrate = 0.8 / 0.2 = 4.0 > 1
  transmrates <- matrix(0.8, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  n <- 100
  
  set.seed(22222)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Average outbreak should be substantial (> 50% of population)
  mean_final_size <- mean(result)
  expect_true(mean_final_size > 0.5 * popsize)
})

test_that("getFinalSizeDistEscape vaccination reduces average final size", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  n <- 100
  
  # No vaccination
  set.seed(33333)
  result_no_vax <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV = 0)
  
  # With 30% vaccination
  set.seed(33333)
  result_with_vax <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV = 3000)
  
  # Vaccination should reduce mean final size
  expect_true(mean(result_with_vax) < mean(result_no_vax))
})

test_that("getFinalSizeDistEscape handles asymmetric transmission", {
  # Different transmission rates between groups
  transmrates <- matrix(c(0.4, 0.1, 0.2, 0.5), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(800, 200)
  initR <- c(0, 0)
  initI <- c(5, 1)
  initV <- c(80, 20)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 2)
  expect_true(all(result[, 1] >= initI[1] + initR[1]))
  expect_true(all(result[, 2] >= initI[2] + initR[2]))
  expect_true(all(result[, 1] <= popsize[1]))
  expect_true(all(result[, 2] <= popsize[2]))
})

test_that("getFinalSizeDistEscape with all susceptibles vaccinated gives minimal outbreak", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  # Vaccinate almost everyone except initial infected
  initV <- 990
  n <- 50
  
  set.seed(44444)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # All simulations should have minimal outbreak (only initial infected)
  expect_true(all(result <= initI + initR + 10))
})

test_that("getFinalSizeDistEscape works with three groups", {
  transmrates <- matrix(c(0.3, 0.1, 0.05,
                         0.15, 0.4, 0.1,
                         0.1, 0.15, 0.35), 3, 3, byrow = TRUE)
  recoveryrate <- 0.25
  popsize <- c(500, 300, 200)
  initR <- c(0, 0, 0)
  initI <- c(10, 5, 2)
  initV <- c(50, 30, 20)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 3)
  
  # Check all simulations respect bounds
  for (i in 1:n) {
    expect_true(all(result[i, ] >= initI + initR))
    expect_true(all(result[i, ] <= popsize))
  }
})

test_that("getFinalSizeDistEscape handles large initial recovered", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  # Large initial recovered population reduces susceptibles
  initR <- c(800, 800)
  initI <- c(10, 10)
  initV <- c(0, 0)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # All simulations should include initial recovered
  expect_true(all(result[, 1] >= initR[1] + initI[1]))
  expect_true(all(result[, 2] >= initR[2] + initI[2]))
  expect_true(all(result[, 1] <= popsize[1]))
  expect_true(all(result[, 2] <= popsize[2]))
})

test_that("getFinalSizeDistEscape handles equal group sizes symmetrically", {
  # Two identical groups with symmetric transmission
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initI <- c(5, 5)
  initV <- c(50, 50)
  n <- 200
  
  set.seed(66666)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With symmetric setup, means should be similar
  mean1 <- mean(result[, 1])
  mean2 <- mean(result[, 2])
  expect_equal(mean1, mean2, tolerance = 10)
})

test_that("getFinalSizeDistEscape handles zero susceptibles correctly", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(100, 100)
  # Everyone is either recovered or vaccinated
  initR <- c(50, 60)
  initI <- c(0, 0)
  initV <- c(50, 40)
  n <- 20
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With no susceptibles and no infected, final size is just initial recovered
  # All simulations should be identical
  expect_true(all(result[, 1] == initR[1]))
  expect_true(all(result[, 2] == initR[2]))
})

test_that("getFinalSizeDistEscape handles different initial infections per group", {
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  initR <- c(0, 0)
  # Heavy infection in first group, light in second
  initI <- c(100, 1)
  initV <- c(100, 100)
  n <- 100
  
  set.seed(77777)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # First group should have larger average final size
  expect_true(mean(result[, 1]) > mean(result[, 2]))
})

test_that("getFinalSizeDistEscape final size includes initial recovered", {
  transmrates <- matrix(0.3, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(50, 100)
  initI <- c(5, 5)
  initV <- c(50, 50)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Every simulation must include all initial recovered
  expect_true(all(result[, 1] >= initR[1]))
  expect_true(all(result[, 2] >= initR[2]))
})

test_that("getFinalSizeDistEscape works with four groups", {
  transmrates <- matrix(0.3, 4, 4)
  recoveryrate <- 0.2
  popsize <- c(250, 250, 250, 250)
  initR <- c(0, 0, 0, 0)
  initI <- c(5, 5, 5, 5)
  initV <- c(25, 25, 25, 25)
  n <- 50
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 4)
  
  for (i in 1:n) {
    expect_true(all(result[i, ] >= initI + initR))
    expect_true(all(result[i, ] <= popsize))
  }
})

test_that("getFinalSizeDistEscape with isolated groups", {
  # No transmission between groups (diagonal transmission only)
  transmrates <- matrix(c(0.5, 0, 0, 0.5), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  initR <- c(0, 0)
  initI <- c(10, 0)  # Only group 1 starts infected
  initV <- c(0, 0)
  n <- 100
  
  set.seed(99999)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Group 2 should never get infected (remains at initR + initI = 0)
  expect_true(all(result[, 2] == initR[2] + initI[2]))
  # Group 1 should have outbreaks
  expect_true(mean(result[, 1]) > initR[1] + initI[1] + 10)
})

test_that("getFinalSizeDistEscape handles small number of simulations", {
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(50, 30)
  n <- 5  # Very small sample
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), 5)
  expect_equal(ncol(result), 2)
})

test_that("getFinalSizeDistEscape handles large number of simulations", {
  transmrates <- matrix(0.3, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(200, 200)
  initR <- c(0, 0)
  initI <- c(5, 5)
  initV <- c(20, 20)
  n <- 1000  # Large sample
  
  set.seed(10101)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(nrow(result), 1000)
  expect_equal(ncol(result), 2)
})

test_that("getFinalSizeDistEscape respects population constraints in all simulations", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(100, 200)
  initR <- c(10, 20)
  initI <- c(5, 10)
  initV <- c(15, 30)
  n <- 100
  
  # S + I + R + V should equal popsize at start
  initS <- popsize - initR - initI - initV
  expect_equal(initS, c(70, 140))
  
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Check every single simulation
  for (i in 1:n) {
    expect_true(all(result[i, ] <= popsize))
  }
})

test_that("getFinalSizeDistEscape escaped outbreaks match ODE solution", {
  # High transmission ensures outbreak will escape threshold
  transmrates <- matrix(0.8, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(5000, 3000)
  initR <- c(0, 0)
  initI <- c(50, 30)  # High initial infection to trigger escape
  initV <- c(0, 0)
  n <- 100
  
  set.seed(88888)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Get ODE solution
  ode_result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With high R0 and initial infection, most/all simulations should escape
  # and converge to ODE solution (rounded)
  escaped_sims <- apply(result, 1, function(x) all(x == round(ode_result)))
  
  # Expect high proportion of escaped simulations
  expect_true(mean(escaped_sims) > 0.8)
})

test_that("getFinalSizeDistEscape with low transmission shows stochastic die-outs", {
  # Near-critical R0 = 1.25 should show bimodal behavior
  transmrates <- matrix(0.25, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 5
  initV <- 0
  n <- 200
  
  set.seed(13579)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should have some die-outs (near initial size) and some escapes (large outbreaks)
  small_outbreaks <- sum(result < 100)
  large_outbreaks <- sum(result > 1000)
  
  # Expect bimodal distribution: some die out, some escape
  expect_true(small_outbreaks > 10)
  expect_true(large_outbreaks > 10)
})

test_that("getFinalSizeDistEscape approximates getFinalSizeDist for moderate outbreaks", {
  # Use moderate transmission where some outbreaks escape, some don't
  transmrates <- matrix(0.35, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(800, 600)
  initR <- c(0, 0)
  initI <- c(5, 3)
  initV <- c(80, 60)
  n <- 200
  
  set.seed(24680)
  result_escape <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  set.seed(24680)
  result_regular <- getFinalSizeDist(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Means should be similar between the two methods
  mean_escape <- colMeans(result_escape)
  mean_regular <- colMeans(result_regular)
  
  # Allow reasonable tolerance since escape method switches to ODE
  expect_equal(mean_escape[1], mean_regular[1], tolerance = 20)
  expect_equal(mean_escape[2], mean_regular[2], tolerance = 20)
})

test_that("getFinalSizeDistEscape reduces variance for large escaped outbreaks", {
  # High R0 ensures most outbreaks escape
  transmrates <- matrix(0.9, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 20
  initV <- 0
  n <- 200
  
  set.seed(11223)
  result_escape <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  set.seed(11223)
  result_regular <- getFinalSizeDist(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Escape method should have lower variance since escaped outbreaks
  # all converge to same ODE solution
  var_escape <- var(result_escape)
  var_regular <- var(result_regular)
  
  # Escape method should have less variance
  expect_true(var_escape < var_regular)
})

test_that("getFinalSizeDistEscape handles very small initial infection", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(5000, 3000)
  initR <- c(0, 0)
  initI <- c(1, 0)  # Single initial infection
  initV <- c(0, 0)
  n <- 100
  
  set.seed(33221)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should have mix of die-outs and escapes
  expect_equal(nrow(result), n)
  expect_equal(ncol(result), 2)
  # Check bounds for each group separately
  expect_true(all(result[, 1] >= initI[1] + initR[1]))
  expect_true(all(result[, 2] >= initI[2] + initR[2]))
  expect_true(all(result[, 1] <= popsize[1]))
  expect_true(all(result[, 2] <= popsize[2]))
})

test_that("getFinalSizeDistEscape escape threshold works correctly", {
  # Design scenario where we can detect if escape mechanism is used
  # High transmission with large population
  transmrates <- matrix(1.0, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 30  # Enough to likely trigger escape
  initV <- 0
  n <- 50
  
  set.seed(99887)
  result <- getFinalSizeDistEscape(n, transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Get ODE solution
  ode_result <- round(getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV))
  
  # Count how many simulations exactly match the rounded ODE result
  exact_matches <- sum(result == ode_result)
  
  # With high R0 and initial infection, should have many escapes
  # (exact matches to ODE solution)
  expect_true(exact_matches > 25)
})
