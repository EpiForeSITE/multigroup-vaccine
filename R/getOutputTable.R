getOutputTable <- function(agelims, agepops, agecovr, ageveff, initgrp) {

  grpnames <- c(
    paste0("under", agelims[2]),
    paste0(agelims[2:(length(agelims) - 1)], "to", agelims[3:length(agelims)] - 1),
    paste0(agelims[length(agelims)], "+")
  )

  agevacimmune <- round(agepops * agecovr * ageveff)

  mij <- contactMatrixPolymod(agelims, agepops)

  pops <- agepops
  initV <- agevacimmune

  initI <- rep(0, length(pops))
  initI[initgrp] <- 1
  initR <- rep(0, length(pops))

  R0vals <- 10:18
  meaninf <- 7

  Rv <- rep(0, length(R0vals))
  escapesize <- matrix(0, length(R0vals), length(pops))

  for (i in seq_along(R0vals)) {
    betaij <- transmissionRates(
      R0 = R0vals[i],
      meaninf = meaninf,
      reltransm = mij
    )
    Rv[i] <- repnum(meaninf, agepops, betaij, initR, agecovr * agepops, ageveff)

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

  numsims <- 10000

  probescape <- rep(0, length(R0vals))
  for (i in seq_along(R0vals)) {
    if (Rv[i] < 1) {
      probescape[i] <- 0
    } else {
      betaij <- transmissionRates(
        R0 = R0vals[i],
        meaninf = meaninf,
        reltransm = mij
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

  tbl <- cbind(R0vals, Rv, probescape, round(escapesizetot), round(escapesize))
  colnames(tbl) <- c("R0", "Rv", "pEscape", "escapeInfTot", grpnames)
  tbl
}
