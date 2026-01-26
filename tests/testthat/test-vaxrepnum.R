test_that("vaxrepnum returns numeric value", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  initV <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_type(result, "double")
  expect_length(result, 1)
  expect_true(is.finite(result))
})

test_that("vaxrepnum vaccination reduces reproduction number", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # No vaccination
  result_no_vax <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 0), vaxeff)
  
  # With vaccination
  result_with_vax <- vaxrepnum(meaninf, popsize, trmat, initR, c(160, 750), vaxeff)
  
  # Vaccination should reduce reproduction number
  expect_true(result_with_vax < result_no_vax)
})

test_that("vaxrepnum handles single group", {
  meaninf <- 7
  popsize <- 1000
  initR <- 0
  initV <- 0
  vaxeff <- 1
  trmat <- matrix(0.5, 1, 1)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  # Should equal transmission rate * mean infectious period
  expected <- trmat[1, 1] * meaninf
  expect_equal(result, expected)
})

test_that("vaxrepnum handles three groups", {
  meaninf <- 5
  popsize <- c(500, 300, 200)
  initR <- c(0, 0, 0)
  initV <- c(50, 30, 20)
  vaxeff <- 0.9
  trmat <- matrix(c(0.4, 0.1, 0.05,
                    0.15, 0.5, 0.1,
                    0.1, 0.15, 0.45), 3, 3, byrow = TRUE)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_type(result, "double")
  expect_length(result, 1)
  expect_true(is.finite(result))
  expect_true(result > 0)
})

test_that("vaxrepnum handles four groups", {
  meaninf <- 6
  popsize <- c(250, 250, 250, 250)
  initR <- c(0, 0, 0, 0)
  initV <- c(50, 50, 50, 50)
  vaxeff <- 0.85
  trmat <- matrix(0.3, 4, 4)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_type(result, "double")
  expect_length(result, 1)
  expect_true(result > 0)
})

test_that("vaxrepnum with complete vaccination approaches zero", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  initV <- c(200, 800)  # Everyone vaccinated
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  # With everyone vaccinated (100% efficacy), R should be 0
  expect_equal(result, 0)
})

test_that("vaxrepnum vaccine effectiveness parameter works correctly", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  initV <- c(100, 400)
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # 100% effective vaccine
  result_100 <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff = 1.0)
  
  # 50% effective vaccine
  result_50 <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff = 0.5)
  
  # 0% effective vaccine (no effect)
  result_0 <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff = 0)
  
  # No vaccination baseline
  result_none <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 0), vaxeff = 1.0)
  
  # Higher effectiveness should give lower reproduction number
  expect_true(result_100 < result_50)
  expect_true(result_50 < result_0)
  # 0% effectiveness should equal no vaccination
  expect_equal(result_0, result_none)
})

test_that("vaxrepnum handles natural immunity", {
  meaninf <- 7
  popsize <- c(200, 800)
  initV <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # No immunity
  result_no_immunity <- vaxrepnum(meaninf, popsize, trmat, c(0, 0), initV, vaxeff)
  
  # Some natural immunity
  result_with_immunity <- vaxrepnum(meaninf, popsize, trmat, c(100, 400), initV, vaxeff)
  
  # Natural immunity should reduce reproduction number
  expect_true(result_with_immunity < result_no_immunity)
})

test_that("vaxrepnum handles combination of natural immunity and vaccination", {
  meaninf <- 7
  popsize <- c(200, 800)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # Baseline
  result_none <- vaxrepnum(meaninf, popsize, trmat, c(0, 0), c(0, 0), vaxeff)
  
  # Only natural immunity
  result_immunity <- vaxrepnum(meaninf, popsize, trmat, c(50, 200), c(0, 0), vaxeff)
  
  # Only vaccination
  result_vax <- vaxrepnum(meaninf, popsize, trmat, c(0, 0), c(50, 200), vaxeff)
  
  # Both immunity and vaccination
  result_both <- vaxrepnum(meaninf, popsize, trmat, c(50, 200), c(50, 200), vaxeff)
  
  # All should reduce R compared to baseline
  expect_true(result_immunity < result_none)
  expect_true(result_vax < result_none)
  expect_true(result_both < result_immunity)
  expect_true(result_both < result_vax)
})

test_that("vaxrepnum with all population immune gives zero", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(200, 800)  # Everyone recovered/immune
  initV <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_equal(result, 0)
})

test_that("vaxrepnum handles symmetric transmission matrix", {
  meaninf <- 7
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initV <- c(50, 50)
  vaxeff <- 1
  trmat <- matrix(0.5, 2, 2)  # Symmetric
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  # With symmetric setup and equal vaccination, should get consistent result
  expect_true(result > 0)
  expect_true(is.finite(result))
})

test_that("vaxrepnum handles asymmetric transmission matrix", {
  meaninf <- 7
  popsize <- c(800, 200)
  initR <- c(0, 0)
  initV <- c(80, 20)
  vaxeff <- 0.8
  trmat <- matrix(c(0.6, 0.1, 0.3, 0.7), 2, 2)  # Asymmetric
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_type(result, "double")
  expect_true(result > 0)
})

test_that("vaxrepnum scales with mean infectious period", {
  popsize <- c(200, 800)
  initR <- c(0, 0)
  initV <- c(20, 80)
  vaxeff <- 0.9
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # Shorter infectious period
  result_short <- vaxrepnum(5, popsize, trmat, initR, initV, vaxeff)
  
  # Longer infectious period
  result_long <- vaxrepnum(10, popsize, trmat, initR, initV, vaxeff)
  
  # Longer infectious period should give higher reproduction number
  expect_true(result_long > result_short)
  
  # Should scale linearly
  expect_equal(result_long / result_short, 10 / 5)
})

test_that("vaxrepnum with different population sizes", {
  meaninf <- 7
  initR <- c(0, 0)
  initV <- c(10, 40)
  vaxeff <- 1
  trmat <- matrix(c(0.5, 0.2, 0.2, 0.5), 2, 2)
  
  # Small populations
  result_small <- vaxrepnum(meaninf, c(100, 100), trmat, initR, initV, vaxeff)
  
  # Large populations (same vaccination coverage: 10% and 40%)
  result_large <- vaxrepnum(meaninf, c(1000, 1000), trmat, c(0, 0), c(100, 400), vaxeff)
  
  # Same vaccination coverage should give same result
  expect_equal(result_small, result_large)
})

test_that("vaxrepnum handles zero transmission rates", {
  meaninf <- 7
  popsize <- c(500, 500)
  initR <- c(0, 0)
  initV <- c(0, 0)
  vaxeff <- 1
  # No transmission between groups
  trmat <- matrix(c(0.5, 0, 0, 0.5), 2, 2)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  # Should equal max of diagonal elements * meaninf
  expected <- max(diag(trmat)) * meaninf
  expect_equal(result, expected)
})

test_that("vaxrepnum partial vaccination in one group", {
  meaninf <- 7
  popsize <- c(500, 500)
  initR <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.5, 0.2, 0.2, 0.5), 2, 2)
  
  # No vaccination
  result_none <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 0), vaxeff)
  
  # Vaccinate only first group
  result_group1 <- vaxrepnum(meaninf, popsize, trmat, initR, c(250, 0), vaxeff)
  
  # Vaccinate only second group
  result_group2 <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 250), vaxeff)
  
  # Both should reduce R
  expect_true(result_group1 < result_none)
  expect_true(result_group2 < result_none)
  
  # With symmetric transmission and populations, should be equal
  expect_equal(result_group1, result_group2)
})

test_that("vaxrepnum handles partial immunity in different groups", {
  meaninf <- 7
  popsize <- c(500, 500)
  initV <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.5, 0.2, 0.2, 0.5), 2, 2)
  
  # High immunity in first group, low in second
  result_asymm <- vaxrepnum(meaninf, popsize, trmat, c(400, 50), initV, vaxeff)
  
  # Balanced immunity
  result_balanced <- vaxrepnum(meaninf, popsize, trmat, c(225, 225), initV, vaxeff)
  
  # Both should be valid
  expect_true(result_asymm > 0)
  expect_true(result_balanced > 0)
})

test_that("vaxrepnum increasing vaccination coverage reduces R", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  vaxeff <- 1
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # Increasing vaccination coverage
  result_0 <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 0), vaxeff)
  result_25 <- vaxrepnum(meaninf, popsize, trmat, initR, c(50, 200), vaxeff)
  result_50 <- vaxrepnum(meaninf, popsize, trmat, initR, c(100, 400), vaxeff)
  result_75 <- vaxrepnum(meaninf, popsize, trmat, initR, c(150, 600), vaxeff)
  
  # Should monotonically decrease
  expect_true(result_25 < result_0)
  expect_true(result_50 < result_25)
  expect_true(result_75 < result_50)
})

test_that("vaxrepnum handles edge case: very small vaccine effectiveness", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(0, 0)
  initV <- c(100, 400)
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  # Very small effectiveness
  result_small <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff = 0.001)
  
  # Essentially no vaccination
  result_none <- vaxrepnum(meaninf, popsize, trmat, initR, c(0, 0), vaxeff = 1)
  
  # Should be very close
  expect_equal(result_small, result_none, tolerance = 0.01)
})

test_that("vaxrepnum handles large populations", {
  meaninf <- 7
  popsize <- c(1e6, 2e6)
  initR <- c(1e5, 2e5)
  initV <- c(2e5, 4e5)
  vaxeff <- 0.9
  trmat <- matrix(c(0.5, 0.1, 0.2, 0.6), 2, 2)
  
  result <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  expect_type(result, "double")
  expect_true(is.finite(result))
  expect_true(result > 0)
})

test_that("vaxrepnum is deterministic", {
  meaninf <- 7
  popsize <- c(200, 800)
  initR <- c(10, 40)
  initV <- c(40, 160)
  vaxeff <- 0.9
  trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
  
  result1 <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  result2 <- vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
  
  # Should be identical (deterministic calculation)
  expect_equal(result1, result2)
})
