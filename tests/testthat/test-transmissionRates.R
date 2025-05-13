test_that("transmission rate calibration works", {
  R0 <- 15
  meaninf <- 7
  popsize <- c(100, 200, 300)
  incontact <- c(0.3, 0.4, 0.45)
  relcontact <- c(1, 1.1, 1.4)
  relsusc <- c(1, 1.2, 1.1)

  betaij <- transmissionRates(R0, meaninf, popsize, incontact, relcontact, relsusc)

  expect_equal(eigen(betaij)$values[1] * meaninf, R0)

  beta11 <- relcontact[1] * relsusc[1] * (incontact[1] + (1-incontact[1])^2 * relcontact[1] *
                                            popsize[1] / sum((1 - incontact) * relcontact * popsize))

  beta22 <- relcontact[2] * relsusc[2] * (incontact[2] + (1-incontact[2])^2 * relcontact[2] *
                                            popsize[2] / sum((1 - incontact) * relcontact * popsize))

  beta33 <- relcontact[3] * relsusc[3] * (incontact[3] + (1-incontact[3])^2 * relcontact[3] *
                                            popsize[3] / sum((1 - incontact) * relcontact * popsize))

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

  betamat <- rbind(c(beta11, beta12, beta13), c(beta21, beta22, beta23), c(beta31 ,beta32, beta33))

  betachk <- betamat * R0 / meaninf / eigen(betamat)$values[1]
  expect_equal(max(abs(betaij-betachk)), 0, tolerance = sqrt(.Machine$double.eps))
})
