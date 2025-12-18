#' Ordinary differential equation function for multi-group susceptible-infectious-removed (SIR) model
#' used as "func" argument passed to the ode() function from deSolve package
#' @param time vector of times at which the function will be evaluated
#' @param state vector of number of individuals in each group at each state: S states
#' followed by I states followed by R states
#' @param par vector of parameter values: group-to-group transmission rate matrix elements (row-wise)
#' followed by recovery rate
#' @export
odeSIR <- function(time, state, par) {
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
