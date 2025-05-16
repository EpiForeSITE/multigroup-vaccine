library(multigroup.vaccine)


test_that("final size calculation works: vax at time 0", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  incontact <- c(0.4, 0.4)

  fs <- getFinalSize(0, vacPortion, popsize, R0, recoveryRate, contactRatio, incontact, suscRatio)
  #expect_equal(length(fs), length(popsize))

  time <- 1 / recoveryRate * 1000
  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- vacPortion * popsize
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  fssim <- getSizeAtTime(time, R0, recoveryRate, popsize, initR, initI, initV, incontact, relcontact, relsusc)
  expect_equal(max(abs(fssim$activeSize)), 0, tolerance = sqrt(.Machine$double.eps))
  expect_equal(max(abs(fssim$totalSize - fs)), 0, tolerance = 1)
})

test_that("final size calculation works: delayed vax", {
  vacPortion <- c(0.1, 0.1)
  popsize <- c(80000, 20000)
  R0 <- 1.5
  recoveryRate <- 1 / 7
  contactRatio <- 1.7
  suscRatio <- 1.1
  incontact <- c(0.4, 0.4)
  vacTime <- 50

  fs <- getFinalSize(vacTime, vacPortion, popsize, R0, recoveryRate, contactRatio, incontact, suscRatio)
  expect_equal(length(fs), length(popsize))

  time <- 1 / recoveryRate * 1000
  initR <- c(0, 0)
  initI <- popsize / sum(popsize)
  initV <- c(0, 0)
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)
  initsim <- getSizeAtTime(vacTime, R0, recoveryRate, popsize, initR, initI, initV, incontact, relcontact, relsusc)
  vacI <- initsim$activeSize
  vacR <- initsim$totalSize - vacI
  vacV <- vacPortion * popsize
  fssim <- getSizeAtTime(time, R0, recoveryRate, popsize, vacR, vacI, vacV, incontact, relcontact, relsusc)

  expect_equal(max(abs(fssim$activeSize)), 0, tolerance = sqrt(.Machine$double.eps))
  expect_equal(max(abs(fssim$totalSize - fs)), 0, tolerance = 1)
})
