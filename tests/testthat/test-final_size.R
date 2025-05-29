library(multigroup.vaccine)


test_that("final size calculation works: 2 groups, vax at time 0", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  incontact <- c(0.4, 0.4)

  fs <- getFinalSize(0, vacPortion, popsize, R0, recoveryRate, c(1, contactRatio), incontact, c(1, suscRatio))
  expect_equal(length(fs), length(popsize))

  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  f <- (1 - incontact) * relcontact * popsize
  contactmatrix <- (diag(incontact) + outer((1 - incontact), f / sum(f)))
  reltransm <- relcontact * relsusc * contactmatrix
  transmrates <- transmissionRates(R0, 1 / recoveryRate, reltransm)
  fssim <- getFinalSizeODE(transmrates, recoveryRate, popsize, initR, initI, initV)
  expect_equal(max(abs(fssim$activeSize)), 0, tolerance = sqrt(.Machine$double.eps))
  expect_equal(max(abs(fssim$totalSize - fs)), 0, tolerance = 1)
})

test_that("final size calculation works: 2 groups, delayed vax", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  incontact <- c(0.4, 0.4)
  vacTime <- 50

  fs <- getFinalSize(vacTime, vacPortion, popsize, R0, recoveryRate, c(1, contactRatio), incontact, c(1, suscRatio))
  expect_equal(length(fs), length(popsize))

  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- c(0, 0)
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  f <- (1 - incontact) * relcontact * popsize
  contactmatrix <- (diag(incontact) + outer((1 - incontact), f / sum(f)))
  reltransm <- relcontact * relsusc * contactmatrix
  transmrates <- transmissionRates(R0, 1 / recoveryRate, reltransm)

  initsim <- getSizeAtTime(vacTime, R0, recoveryRate, popsize, initR, initI, initV, contactmatrix, relcontact, relsusc)
  vacI <- initsim$activeSize
  vacR <- initsim$totalSize - vacI
  vacV <- vacPortion * popsize

  fssim <- getFinalSizeODE(transmrates, recoveryRate, popsize, vacR, vacI, vacV)

  expect_equal(max(abs(fssim$activeSize)), 0, tolerance = sqrt(.Machine$double.eps))
  expect_equal(max(abs(fssim$totalSize - fs)), 0, tolerance = 1)
})

test_that("final size calculation works: 3 groups, vax at time 0", {
  vacPortion <- c(0.9, 0.8, 0.7)
  popsize <- c(80000, 1000, 500)
  R0 <- 15
  recoveryRate <- 1 / 7
  relcontact <- rep(1, 3)
  relsusc <- rep(1, 3)
  incontact <- rep(0.8, 3)

  fs <- getFinalSize(0, vacPortion, popsize, R0, recoveryRate, relcontact, incontact, relsusc)
  expect_equal(length(fs), length(popsize))

  initR <- rep(0, length(popsize))
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize
  f <- (1 - incontact) * relcontact * popsize
  contactmatrix <- (diag(incontact) + outer((1 - incontact), f / sum(f)))
  reltransm <- relcontact * relsusc * contactmatrix
  transmrates <- transmissionRates(R0, 1 / recoveryRate, reltransm)
  fssim <- getFinalSizeODE(transmrates, recoveryRate, popsize, initR, initI, initV)
  expect_equal(max(abs(fssim$activeSize)), 0, tolerance = sqrt(.Machine$double.eps))
  expect_equal(max(abs(fssim$totalSize - fs)), 0, tolerance = 1)
})
