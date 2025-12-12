#' Gets full histogram of final sizes for an age-structured population
#' @param R0 basic reproduction number
#' @param agelims Vector of age group limits
#' @param agepops Vector of population sizes for each age group
#' @param agecovr Vector of vaccination coverage rates for each age group
#' @param ageveff Vector of vaccine effectiveness rates for each age group
#' @param initgrp Index of the age group where the initial infection occurs
#' @returns A data frame with columns for final size and frequency
#' @keywords internal
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
