# TODO: Add more tests if tests are necessary for this function

test_that("odeSIR returns correct structure", {
  # Setup for 2 groups
  state <- c(S1 = 990, S2 = 990, I1 = 10, I2 = 10, R1 = 0, R2 = 0)
  transmrates <- matrix(c(0.0003, 0.0001, 0.0001, 0.0003), 2, 2)
  popsize <- c(1000, 1000)
  betaoverNj <- t(t(transmrates) / popsize)
  parms <- c(betaoverNj, recoveryrate = 0.2)
  time <- 0
  
  result <- odeSIR(time, state, parms)
  
  # Should return a list with one element (vector of derivatives)
  expect_type(result, "list")
  expect_equal(length(result), 1)
  # Derivative vector should have same length as state
  expect_equal(length(result[[1]]), length(state))
})
