#' Ordinary differential equation function for multi-group susceptible-infectious-removed (SIR) model
#' used as "func" argument passed to the ode() function from deSolve package
#' @param time vector of times at which the function will be evaluated
#' @param state vector of number of individuals in each group at each state: S states
#' followed by I states followed by R states
#' @param par vector of parameter values: group-to-group transmission rate matrix elements (row-wise)
#' followed by recovery rate
#' @returns a list of three vectors of derivatives dS, dI, and dR for each group, evaluated at the
#' given state values
#' @examples
#' # Intended only for use as the func argument to the ode() function from the deSolve package:
#' y0 <- c(S1 = 79999, S2 = 20000, I1 = 1, I2 = 0, R1 = 0, R2 = 0)
#' parms <- c(beta11 = 1.6e-6, beta21 = 1.5e-6, beta12 = 1.4e-6, beta22 = 8.7e-6, recoveryrate = 1/7)
#' times <- seq(0, 350, len = 10)
#' deSolve::ode(y0, times, odeSIR, parms)
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
