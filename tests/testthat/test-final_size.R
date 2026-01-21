library(multigroup.vaccine)

test_that("determinisitc final size calculations agree: 2 groups, vax at time 0", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  contactRatio <- 1.7
  suscRatio <- 1.1
  transmRatio <- 1.05
  incontact <- c(0.4, 0.4)

  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  reltransm <- c(1, transmRatio)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))

  #f <- (1 - incontact) * relcontact * popsize
  #contactmatrix <- (diag(incontact) + outer((1 - incontact), f / sum(f)))

  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})

test_that("deterministic final size calculations agree: 2 groups, delayed vax", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  transmRatio <- 1.05
  incontact <- c(0.4, 0.4)
  vacTime <- 50

  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- c(0, 0)
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  reltransm <- c(1, transmRatio)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  transmmatrix <- transmissionRates(R0, 1 / recoveryRate, relsusc * t(reltransm * t(contactmatrix)))

  initsim <- getSizeAtTime(vacTime, transmmatrix, recoveryRate, popsize, initR, initI, initV)
  vacI <- initsim$activeSize
  vacR <- initsim$totalSize - vacI
  vacV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, vacR, vacI, vacV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, vacR, vacI, vacV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))
  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})

test_that("final size calculation works: 3 groups, vax at time 0", {
  vacPortion <- c(0.9, 0.8, 0.7)
  popsize <- c(80000, 1000, 500)
  R0 <- 15
  relcontact <- rep(1, 3)
  relsusc <- rep(1, 3)
  reltransm <- rep(1, 3)
  incontact <- rep(0.8, 3)

  contactmatrix <- contactMatrixPropPref(popsize, relcontact, incontact)
  initR <- c(0, 0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize

  fsODE <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE")
  fsAnalytic <- finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "analytic")

  expect_equal(length(fsODE), length(popsize))
  expect_equal(length(fsAnalytic), length(popsize))

  expect_equal(max(abs(fsODE - fsAnalytic)), 0, tolerance = 1)
})
