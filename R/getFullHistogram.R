getFullHistogram <- function(R0, agelims, agepops, agecovr, ageveff, initgrp) {

  agevacimmune <- round(agepops * agecovr * ageveff)

  mij <- contactMatrixPolymod(agelims, agepops)

  pops <- agepops
  initV <- agevacimmune

  initI <- rep(0, length(pops))
  initI[initgrp] <- 1
  initR <- rep(0, length(pops))

  meaninf <- 7

  betaij <- transmissionRates(
    R0 = R0,
    meaninf = meaninf,
    reltransm = mij
  )

  numsims <- 1000

  betaij <- transmissionRates(
    R0 = R0,
    meaninf = meaninf,
    reltransm = mij
  )
  size_dist <- getFinalSizeDist(
    n = numsims,
    transmrates = betaij,
    recoveryrate = 1 / meaninf,
    popsize = pops,
    initR = initR,
    initV = initV,
    initI = initI
  )
  size_dist
}
