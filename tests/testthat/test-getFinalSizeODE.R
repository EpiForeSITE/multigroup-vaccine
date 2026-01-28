test_that("getFinalSizeODE returns correct dimensions", {
  transmrates <- matrix(0.2, 2, 2)
  recoveryrate <- 0.3
  popsize <- c(100, 150)
  initR <- c(0, 0)
  initI <- c(1, 0)
  initV <- c(10, 10)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), length(popsize))
  expect_type(result, "double")
})

test_that("getFinalSizeODE final size is bounded by population", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 500)
  initR <- c(0, 0)
  initI <- c(10, 5)
  initV <- c(50, 25)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size should not exceed population size
  expect_true(all(result <= popsize))
  # Final size should be at least the initial infected + recovered
  expect_true(all(result >= initI + initR))
})

test_that("getFinalSizeODE is deterministic", {
  transmrates <- matrix(c(0.3, 0.1, 0.15, 0.25), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(50, 30)
  
  result1 <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  result2 <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # ODE solver is deterministic - results should be identical
  expect_equal(result1, result2)
})

test_that("getFinalSizeODE handles single group", {
  transmrates <- matrix(0.3, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  initV <- 100
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 1)
  expect_true(result >= initI + initR)
  expect_true(result <= popsize)
})

test_that("getFinalSizeODE with R0 < 1 has small outbreak", {
  # R0 = transmrate / recoveryrate = 0.15 / 0.2 = 0.75 < 1
  transmrates <- matrix(0.15, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With R0 < 1, outbreak should be small (less than 5% of population)
  expect_true(result < 0.05 * popsize)
})

test_that("getFinalSizeODE with high R0 has large outbreak", {
  # R0 = transmrate / recoveryrate = 0.8 / 0.2 = 4.0 > 1
  transmrates <- matrix(0.8, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With R0 = 4, outbreak should be substantial (> 50% of population)
  expect_true(result > 0.5 * popsize)
})

test_that("getFinalSizeODE vaccination reduces final size", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  
  # No vaccination
  result_no_vax <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV = 0)
  
  # With 30% vaccination
  result_with_vax <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV = 3000)
  
  # Vaccination should reduce final size
  expect_true(result_with_vax < result_no_vax)
})

test_that("getFinalSizeODE handles asymmetric transmission", {
  # Different transmission rates between groups
  transmrates <- matrix(c(0.4, 0.1, 0.2, 0.5), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(800, 200)
  initR <- c(0, 0)
  initI <- c(5, 1)
  initV <- c(80, 20)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 2)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeODE with all susceptible vaccinated gives minimal outbreak", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  # Vaccinate almost everyone except initial infected
  initV <- 990
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Only initial infected should be in final size (no transmission possible)
  expect_true(result <= initI + initR + 10)  # Small tolerance
})

test_that("getFinalSizeODE handles large initial recovered", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  # Large initial recovered population reduces susceptibles
  initR <- c(800, 800)
  initI <- c(10, 10)
  initV <- c(0, 0)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size should include initial recovered
  expect_true(all(result >= initR + initI))
  expect_true(all(result <= popsize))
  # With so many already recovered, outbreak should be relatively small
  additional_infections <- result - initR - initI
  remaining_susceptibles <- popsize - initR - initI - initV
  expect_true(all(additional_infections < remaining_susceptibles))
})

test_that("getFinalSizeODE works with three groups", {
  transmrates <- matrix(c(0.3, 0.1, 0.05,
                         0.15, 0.4, 0.1,
                         0.1, 0.15, 0.35), 3, 3, byrow = TRUE)
  recoveryrate <- 0.25
  popsize <- c(500, 300, 200)
  initR <- c(0, 0, 0)
  initI <- c(10, 5, 2)
  initV <- c(50, 30, 20)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 3)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeODE handles equal group sizes", {
  # Two identical groups with symmetric transmission
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initI <- c(5, 5)
  initV <- c(50, 50)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With symmetric setup, results should be very similar (within numerical tolerance)
  expect_equal(result[1], result[2], tolerance = 1e-3)
})

test_that("getFinalSizeODE final size increases with higher transmission", {
  recoveryrate <- 0.2
  popsize <- 5000
  initR <- 0
  initI <- 10
  initV <- 0
  
  # Low transmission (R0 = 1.25)
  result_low <- getFinalSizeODE(matrix(0.25, 1, 1), recoveryrate, popsize, initR, initI, initV)
  
  # Medium transmission (R0 = 2.0)
  result_med <- getFinalSizeODE(matrix(0.4, 1, 1), recoveryrate, popsize, initR, initI, initV)
  
  # High transmission (R0 = 3.0)
  result_high <- getFinalSizeODE(matrix(0.6, 1, 1), recoveryrate, popsize, initR, initI, initV)
  
  # Higher transmission should give larger outbreaks
  expect_true(result_low < result_med)
  expect_true(result_med < result_high)
})

test_that("getFinalSizeODE respects population constraints", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(100, 200)
  initR <- c(10, 20)
  initI <- c(5, 10)
  initV <- c(15, 30)
  
  # S + I + R + V should equal popsize at start
  initS <- popsize - initR - initI - initV
  expect_equal(initS, c(70, 140))
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size cannot exceed population
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeODE agrees with getFinalSizeAnalytic", {
  # Both methods should give very similar results
  transmrates <- matrix(c(0.3, 0.1, 0.15, 0.25), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(800, 400)
  initR <- c(0, 0)
  initI <- c(10, 5)
  initV <- c(80, 40)
  
  result_ode <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  set.seed(12345)
  result_analytic <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Should agree within small tolerance (ODE numerical error + analytic optimization)
  expect_equal(result_ode, result_analytic, tolerance = 2)
})

test_that("getFinalSizeODE handles zero susceptibles correctly", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(100, 100)
  # Everyone is either recovered or vaccinated
  initR <- c(50, 60)
  initI <- c(0, 0)
  initV <- c(50, 40)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With no susceptibles and no infected, final size is just initial recovered
  expect_equal(result, initR)
})

test_that("getFinalSizeODE handles different initial infections per group", {
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  initR <- c(0, 0)
  # Heavy infection in first group, light in second
  initI <- c(100, 1)
  initV <- c(100, 100)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 2)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
  # First group should have larger final size due to higher initial infection
  expect_true(result[1] > result[2])
})

test_that("getFinalSizeODE final size includes initial recovered", {
  transmrates <- matrix(0.3, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(50, 100)
  initI <- c(5, 5)
  initV <- c(50, 50)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size must include all initial recovered
  expect_true(all(result >= initR))
})

test_that("getFinalSizeODE handles very small initial infection", {
  transmrates <- matrix(0.4, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 0.1  # Fractional infection (spark)
  initV <- 0
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With R0 = 2, even small spark should cause outbreak
  expect_true(result > 100)
  expect_true(result <= popsize)
})

test_that("getFinalSizeODE works with four groups", {
  transmrates <- matrix(0.3, 4, 4)
  recoveryrate <- 0.2
  popsize <- c(250, 250, 250, 250)
  initR <- c(0, 0, 0, 0)
  initI <- c(5, 5, 5, 5)
  initV <- c(25, 25, 25, 25)
  
  result <- getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 4)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})
