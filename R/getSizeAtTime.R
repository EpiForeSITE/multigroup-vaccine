#' Calculate outbreak size at a given time
#' @param time the time at which to calculate the outbreak size
#' @param R0 overall basic reproduction number
#' @param recoveryRate inverse of the mean duration of infectious period
#' @param popsize population size of each group
#' @param initR initial number of each group who have already recovered from infection
#' @param initI initial number of each group who are actively infected
#' @param initV initial number of each group who are vaccinated and had no prior infection
#' @param incontact fraction of each group's contacts that are exclusively within group
#' @param relcontact relative overall contact rates of each group
#' @param relsusc relative susceptibility to infection per contact of each group
#' @returns a list with totalSize (total cumulative infections) and activeSize (total currently infected) in each group at the specified time
#' @export
getSizeAtTime <- function(time, R0, recoveryRate, popsize, initR, initI, initV, incontact, relcontact, relsusc) {

  beta <- transmissionRates(R0, 1 / recoveryRate, popsize, incontact, relcontact, relsusc)
  betaoverNj <- t(t(beta) / popsize)

  odefun <- function(time, state, par) {
    ngrp <- length(state) / 3
    S <- state[1:ngrp]
    I <- state[(ngrp + 1):(2 * ngrp)]
    betaoverNj <- matrix(par[1:(ngrp^2)], nrow = ngrp, ncol = ngrp)
    gam <- par[length(par)]

    dS <- -(betaoverNj %*% I) * S
    dI <- (betaoverNj %*% I) * S - gam * I
    dR <- gam * I

    return(list(c(dS, dI, dR)))
  }

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)
  parms <- c(betaoverNj, recoveryRate)
  times <- seq(0, time, len = 1000)

  sim <- deSolve::ode(y0, times, odefun, parms)
  Isim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) + 1):(length(popsize) * 2)])
  Rsim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) * 2 + 1):(length(popsize) * 3)])

  list(totalSize = Isim + Rsim, activeSize = Isim)
}
