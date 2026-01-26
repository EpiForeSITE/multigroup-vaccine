test_that("transmission rate calibration works", {
  R0 <- 15
  meaninf <- 7
  popsize <- c(100, 200, 300)
  incontact <- c(0.3, 0.4, 0.45)
  relcontact <- c(1, 1.1, 1.4)
  relsusc <- c(1, 1.2, 1.1)

  f <- (1 - incontact) * relcontact * popsize
  contactmatrix <- (diag(incontact) + outer((1 - incontact), f / sum(f)))
  reltransm <- relcontact * relsusc * contactmatrix
  betaij <- transmissionRates(R0, meaninf, reltransm)

  expect_equal(eigen(betaij)$values[1] * meaninf, R0)

  beta11 <- relcontact[1] * relsusc[1] *
    (incontact[1] + (1 - incontact[1])^2 * relcontact[1] * popsize[1] / sum((1 - incontact) * relcontact * popsize))

  beta22 <- relcontact[2] * relsusc[2] *
    (incontact[2] + (1 - incontact[2])^2 * relcontact[2] * popsize[2] / sum((1 - incontact) * relcontact * popsize))

  beta33 <- relcontact[3] * relsusc[3] *
    (incontact[3] + (1 - incontact[3])^2 * relcontact[3] * popsize[3] / sum((1 - incontact) * relcontact * popsize))

  beta12 <- relcontact[1] * relsusc[1] * (1 - incontact[1]) * (1 - incontact[2]) * relcontact[2] *
    popsize[2] / sum((1 - incontact) * relcontact * popsize)

  beta13 <- relcontact[1] * relsusc[1] * (1 - incontact[1]) * (1 - incontact[3]) * relcontact[3] *
    popsize[3] / sum((1 - incontact) * relcontact * popsize)

  beta21 <- relcontact[2] * relsusc[2] * (1 - incontact[2]) * (1 - incontact[1]) * relcontact[1] *
    popsize[1] / sum((1 - incontact) * relcontact * popsize)

  beta23 <- relcontact[2] * relsusc[2] * (1 - incontact[2]) * (1 - incontact[3]) * relcontact[3] *
    popsize[3] / sum((1 - incontact) * relcontact * popsize)

  beta31 <- relcontact[3] * relsusc[3] * (1 - incontact[3]) * (1 - incontact[1]) * relcontact[1] *
    popsize[1] / sum((1 - incontact) * relcontact * popsize)

  beta32 <- relcontact[3] * relsusc[3] * (1 - incontact[3]) * (1 - incontact[2]) * relcontact[2] *
    popsize[2] / sum((1 - incontact) * relcontact * popsize)

  betamat <- matrix(c(beta11, beta21, beta31, beta12, beta22, beta32, beta13, beta23, beta33), 3, 3)

  betachk <- betamat * R0 / meaninf / eigen(betamat)$values[1]
  expect_equal(max(abs(betaij - betachk)), 0, tolerance = sqrt(.Machine$double.eps))
})

test_that("transmissionRates returns correct dimensions", {
  R0 <- 2.5
  meaninf <- 7
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  expect_true(is.matrix(result))
  expect_equal(dim(result), dim(reltransm))
})

test_that("transmissionRates preserves R0", {
  R0 <- 2.5
  meaninf <- 7
  reltransm <- matrix(c(1, 0.3, 0.5, 1.2), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  # Check that dominant eigenvalue * meaninf equals R0
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates handles symmetric matrix", {
  R0 <- 3
  meaninf <- 6
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)  # Symmetric
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  # Result should also be symmetric
  expect_equal(result[1, 2], result[2, 1])
})

test_that("transmissionRates handles asymmetric matrix", {
  R0 <- 2.8
  meaninf <- 7
  reltransm <- matrix(c(1, 0.3, 0.7, 1.5), 2, 2)  # Asymmetric
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  # Should still preserve R0
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates handles high R0", {
  R0 <- 15
  meaninf <- 7
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  expect_true(all(is.finite(result)))
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates handles low R0", {
  R0 <- 0.5
  meaninf <- 7
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  expect_true(all(result >= 0))
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates handles fractional values", {
  R0 <- 2.73
  meaninf <- 6.5
  reltransm <- matrix(c(1.2, 0.45, 0.67, 1.35), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  expect_true(all(is.finite(result)))
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0, tolerance = 1e-10)
})

test_that("transmissionRates handles large matrices", {
  R0 <- 2.5
  meaninf <- 7
  reltransm <- matrix(runif(100, 0.5, 1.5), 10, 10)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  expect_equal(dim(result), c(10, 10))
  expect_true(all(is.finite(result)))
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates with very short infectious period", {
  R0 <- 3
  meaninf <- 0.5  # Very short
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  # Should have high transmission rates to compensate
  expect_true(all(result > R0 / meaninf * 0.4))  # At least 40% of theoretical max
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})

test_that("transmissionRates with very long infectious period", {
  R0 <- 3
  meaninf <- 30  # Very long
  reltransm <- matrix(c(1, 0.5, 0.5, 1), 2, 2)
  
  result <- transmissionRates(R0, meaninf, reltransm)
  
  # Should have lower transmission rates
  expect_true(all(result < R0 / meaninf * 2))
  computed_R0 <- eigen(result)$values[1] * meaninf
  expect_equal(computed_R0, R0)
})
