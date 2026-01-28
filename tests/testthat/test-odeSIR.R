test_that("odeSIR returns correct structure and values", {
  # Setup for 2 groups
  S1 <- 990; S2 <- 985; I1 <- 10; I2 <- 25; R1 <- 0; R2 <- 0
  N1 <- S1 + I1 + R1; N2 <- S2 + I2 + R2
  beta11 <- 0.0003; beta12 <- 0.0002; beta21 <- 0.0001; beta22 <- 0.0004
  gamma <- 0.2

  state <- c(S1, S2, I1, I2, R1, R2)
  transmrates <- matrix(c(beta11, beta21, beta12, beta22), 2, 2)
  popsize <- c(N1, N2)
  betaoverNj <- t(t(transmrates) / popsize)
  parms <- c(betaoverNj, recoveryrate = gamma)
  time <- 0

  dS1dt <- -(beta11 * I1 / N1 + beta12 * I2 / N2) * S1
  dS2dt <- -(beta21 * I1 / N1 + beta22 * I2 / N2) * S2
  dI1dt <- (beta11 * I1 / N1 + beta12 * I2 / N2) * S1 - gamma * I1
  dI2dt <- (beta21 * I1 / N1 + beta22 * I2 / N2) * S2 - gamma * I2
  dR1dt <- gamma * I1
  dR2dt <- gamma * I2

  result <- odeSIR(time, state, parms)

  # Should return a list with one element (vector of derivatives)
  expect_type(result, "list")
  expect_equal(length(result), 1)
  # Derivative vector should have same length as state
  expect_equal(length(result[[1]]), length(state))
  # Values are correct
  expect_equal(result[[1]][1], dS1dt)
  expect_equal(result[[1]][2], dS2dt)
  expect_equal(result[[1]][3], dI1dt)
  expect_equal(result[[1]][4], dI2dt)
  expect_equal(result[[1]][5], dR1dt)
  expect_equal(result[[1]][6], dR2dt)
})
