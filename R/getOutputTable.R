#' Generate Output Table for Vaccine Model Scenarios
#'
#' This function generates a comprehensive output table showing R0 values,
#' vaccine effectiveness, and escape probabilities for different vaccination
#' scenarios in a multigroup population model.
#'
#' @param agelims Vector of age group limits (lower bounds)
#' @param agepops Vector of population sizes for each age group
#' @param agecovr Vector of vaccination coverage rates for each age group
#' @param ageveff Vector of vaccine effectiveness rates for each age group
#' @param initgrp Index of the age group where the initial infection occurs
#'
#' @return A matrix with columns for R0, R0local, Rv, pEscape, escapeInfTot,
#'   and infection counts by age group
#' @export
getOutputTable <- function(agelims, agepops, agecovr, ageveff, initgrp) {

  grpnames <- c(
    paste0("under", agelims[2]),
    paste0(agelims[2:(length(agelims) - 1)], "to", agelims[3:length(agelims)] - 1),
    paste0(agelims[length(agelims)], "+")
  )

  agevacimmune <- round(agepops * agecovr * ageveff)

  mijpolymod <- contactMatrixPolymod(agelims)
  mijlocal <- contactMatrixPolymod(agelims, agepops)
  R0factor <- eigen(mijlocal)$values[1] / eigen(mijpolymod)$values[1]

  pops <- agepops
  initV <- agevacimmune

  initI <- rep(0, length(pops))
  initI[initgrp] <- 1
  initR <- rep(0, length(pops))

  R0vals <- 10:18
  meaninf <- 7

  R0local <- rep(0, length(R0vals))
  Rv <- rep(0, length(R0vals))
  escapesize <- matrix(0, length(R0vals), length(pops))

  for (i in seq_along(R0vals)) {
    R0local[i] <- R0vals[i] * R0factor

    betaij <- transmissionRates(
      R0 = R0local[i],
      meaninf = meaninf,
      reltransm = mijlocal
    )

    Rv[i] <- vaxrepnum(meaninf, agepops, betaij, initR, agecovr * agepops, ageveff)

    if (Rv[i] < 1) {
      escapesize[i, ] <- rep(0, length(pops))
    } else {
      escapesize[i, ] <- getFinalSizeODE(
        transmrates = betaij,
        recoveryrate = 1 / meaninf,
        popsize = pops,
        initR = initR,
        initI = initI,
        initV = initV
      )$totalSize
    }
    escapesizetot <- rowSums(escapesize)
  }

  numsims <- 1000

  probescape <- rep(0, length(R0vals))
  for (i in seq_along(R0vals)) {
    if (Rv[i] < 1) {
      probescape[i] <- 0
    } else {
      betaij <- transmissionRates(
        R0 = R0local[i],
        meaninf = meaninf,
        reltransm = mijlocal
      )
      size_dist <- getFinalSizeDistEscape(
        n = numsims,
        transmrates = betaij,
        recoveryrate = 1 / meaninf,
        popsize = pops,
        initR = initR,
        initV = initV,
        initI = initI
      )
      probescape[i] <- sum(rowSums(size_dist) > escapesizetot[i] * 0.9) / numsims
    }
  }

  tbl <- cbind(R0vals, R0local, Rv, probescape, round(escapesizetot), round(escapesize))
  colnames(tbl) <- c("R0", "R0local", "Rv", "pEscape", "escapeInfTot", grpnames)
  tbl
}
