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
#' @examples
#' \donttest{
#' # Define age groups: 0-4, 5-17, 18-64, 65+
#' agelims <- c(0, 5, 18, 65)
#' agepops <- c(1000, 3000, 5000, 1500)
#'
#' # Vaccination coverage: none for <5, 80% for school-age, 70% for adults, 90% for elderly
#' agecovr <- c(0, 0.8, 0.7, 0.9)
#'
#' # Vaccine effectiveness: 0% for <5 (not vaccinated), 90% for others
#' ageveff <- c(0, 0.9, 0.9, 0.95)
#'
#' # Initial infection in school-age group (index 2)
#' initgrp <- 2
#'
#' # Generate output table
#' results <- getOutputTable(agelims, agepops, agecovr, ageveff, initgrp)
#' print(results)
#' }
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
      )
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
