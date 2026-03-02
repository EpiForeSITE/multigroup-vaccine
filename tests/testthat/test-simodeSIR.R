test_that("simodeSIR returns correct dimensions", {
  times <- 0:30
  transmrates <- matrix(0.2, 2, 2)
  recoveryrate <- 0.3
  popsize <- c(100, 150)
  initR <- c(0, 0)
  initI <- c(1, 0)
  initV <- c(10, 10)

  result <- simodeSIR(transmrates, recoveryrate, popsize, initR, initI, initV, times)

  # Should return matrix of the correct dimensions
  expect_equal(nrow(result), length(times))
  expect_equal(ncol(result), 1 + length(popsize) * 3)

  # Sum of all compartments should match the non-vaccinated population total
  expect_all_equal(rowSums(result[, -1]), sum(popsize) - sum(initV))
})
