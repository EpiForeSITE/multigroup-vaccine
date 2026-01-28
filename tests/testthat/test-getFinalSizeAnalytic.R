test_that("getFinalSizeAnalytic returns correct dimensions", {
  transmrates <- matrix(0.2, 2, 2)
  recoveryrate <- 0.3
  popsize <- c(100, 150)
  initR <- c(0, 0)
  initI <- c(1, 0)
  initV <- c(10, 10)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), length(popsize))
  expect_type(result, "double")
})

test_that("getFinalSizeAnalytic final size is bounded by population", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 500)
  initR <- c(0, 0)
  initI <- c(10, 5)
  initV <- c(50, 25)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size should not exceed population size
  expect_true(all(result <= popsize))
  # Final size should be at least the initial infected + recovered
  expect_true(all(result >= initI + initR))
})

test_that("getFinalSizeAnalytic is deterministic with set seed", {
  transmrates <- matrix(c(0.3, 0.1, 0.15, 0.25), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(50, 30)
  
  # Set seed for random initialization in optim
  set.seed(1928371)
  result1 <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Reset seed to same value
  set.seed(1928371)
  result2 <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Results should be identical with same seed
  expect_equal(result1, result2)
})

# results should be slightly different with different seeds
test_that("getFinalSizeAnalytic varies with different seeds", {
  transmrates <- matrix(c(0.3, 0.1, 0.15, 0.25), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 300)
  initR <- c(0, 0)
  initI <- c(5, 2)
  initV <- c(50, 30)

  set.seed(111111)
  result1 <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)

  set.seed(222222)
  result2 <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)

  expect_false(all(result1 == result2))
})

test_that("getFinalSizeAnalytic handles single group", {
  transmrates <- matrix(0.3, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  initV <- 100
  
  # Suppress warning about 1-D optimization (known limitation)
  result <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  )
  
  expect_equal(length(result), 1)
  expect_true(result >= initI + initR)
  expect_true(result <= popsize)
})

test_that("getFinalSizeAnalytic with R0 < 1 has small outbreak", {
  # R0 = transmrate / recoveryrate = 0.15 / 0.2 = 0.75 < 1
  transmrates <- matrix(0.15, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  
  result <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  )
  
  # With R0 < 1, outbreak should be small (less than 5% of population)
  expect_true(result < 0.05 * popsize)
})

test_that("getFinalSizeAnalytic with high R0 has large outbreak", {
  # R0 = transmrate / recoveryrate = 0.8 / 0.2 = 4.0 > 1
  transmrates <- matrix(0.8, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  initV <- 0
  
  result <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  )
  
  # With R0 = 4, outbreak should be substantial (> 50% of population)
  expect_true(result > 0.5 * popsize)
})

test_that("getFinalSizeAnalytic vaccination reduces final size", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 10000
  initR <- 0
  initI <- 10
  
  # No vaccination
  result_no_vax <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV = 0)
  )
  
  # With 30% vaccination
  result_with_vax <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV = 3000)
  )
  
  # Vaccination should reduce final size
  expect_true(result_with_vax < result_no_vax)
})

test_that("getFinalSizeAnalytic handles zero initial infections correctly", {
  transmrates <- matrix(0.3, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initI <- c(0, 0)  # No initial infections
  initV <- c(50, 50)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With no initial infections, function defaults to uniform seeding
  # Result should still be valid
  expect_equal(length(result), 2)
  expect_true(all(result >= 0))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeAnalytic handles asymmetric transmission", {
  # Different transmission rates between groups
  transmrates <- matrix(c(0.4, 0.1, 0.2, 0.5), 2, 2)
  recoveryrate <- 0.2
  popsize <- c(800, 200)
  initR <- c(0, 0)
  initI <- c(5, 1)
  initV <- c(80, 20)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 2)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeAnalytic with all susceptible vaccinated gives minimal outbreak", {
  transmrates <- matrix(0.6, 1, 1)
  recoveryrate <- 0.2
  popsize <- 1000
  initR <- 0
  initI <- 10
  # Vaccinate almost everyone except initial infected
  initV <- 990
  
  result <- suppressWarnings(
    getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  )
  
  # Only initial infected should be in final size (no transmission possible)
  expect_true(result <= initI + initR + 10)  # Small tolerance
})

test_that("getFinalSizeAnalytic handles large initial recovered", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  # Large initial recovered population reduces susceptibles
  initR <- c(800, 800)
  initI <- c(10, 10)
  initV <- c(0, 0)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size should include initial recovered
  expect_true(all(result >= initR + initI))
  expect_true(all(result <= popsize))
  # With so many already recovered, outbreak should be relatively small
  # (additional infections should be much less than remaining susceptibles)
  additional_infections <- result - initR - initI
  remaining_susceptibles <- popsize - initR - initI - initV
  expect_true(all(additional_infections < remaining_susceptibles))
})

test_that("getFinalSizeAnalytic works with three groups", {
  transmrates <- matrix(c(0.3, 0.1, 0.05,
                         0.15, 0.4, 0.1,
                         0.1, 0.15, 0.35), 3, 3, byrow = TRUE)
  recoveryrate <- 0.25
  popsize <- c(500, 300, 200)
  initR <- c(0, 0, 0)
  initI <- c(10, 5, 2)
  initV <- c(50, 30, 20)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 3)
  expect_true(all(result >= initI + initR))
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeAnalytic handles equal group sizes", {
  # Two identical groups with symmetric transmission
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initI <- c(5, 5)
  initV <- c(50, 50)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # With symmetric setup, results should be similar (within tolerance)
  expect_equal(result[1], result[2], tolerance = 0.01)
})

test_that("getFinalSizeAnalytic final size increases with higher transmission", {
  recoveryrate <- 0.2
  popsize <- 5000
  initR <- 0
  initI <- 10
  initV <- 0
  
  # Low transmission
  result_low <- suppressWarnings(
    getFinalSizeAnalytic(matrix(0.25, 1, 1), recoveryrate, popsize, initR, initI, initV)
  )
  
  # Medium transmission  
  result_med <- suppressWarnings(
    getFinalSizeAnalytic(matrix(0.4, 1, 1), recoveryrate, popsize, initR, initI, initV)
  )
  
  # High transmission
  result_high <- suppressWarnings(
    getFinalSizeAnalytic(matrix(0.6, 1, 1), recoveryrate, popsize, initR, initI, initV)
  )
  
  # Higher transmission should give larger outbreaks
  expect_true(result_low < result_med)
  expect_true(result_med < result_high)
})

test_that("getFinalSizeAnalytic respects population constraints", {
  transmrates <- matrix(0.5, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(100, 200)
  initR <- c(10, 20)
  initI <- c(5, 10)
  initV <- c(15, 30)
  
  # S + I + R + V should equal popsize at start
  initS <- popsize - initR - initI - initV
  expect_equal(initS, c(70, 140))
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  # Final size (R + initial R) cannot exceed population
  expect_true(all(result <= popsize))
})

test_that("getFinalSizeAnalytic handles fractional initial infections", {
  transmrates <- matrix(0.4, 2, 2)
  recoveryrate <- 0.2
  popsize <- c(1000, 1000)
  initR <- c(0, 0)
  # Fractional initial infections (distributed by population)
  initI <- c(0.8, 0.2)
  initV <- c(100, 100)
  
  result <- getFinalSizeAnalytic(transmrates, recoveryrate, popsize, initR, initI, initV)
  
  expect_equal(length(result), 2)
  expect_true(all(result >= 0))
  expect_true(all(result <= popsize))
})
