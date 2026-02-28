#' Calculate time trajectory of solution to a Susceptible-Infectious-Removed (SIR) system by
#' numerically solving the multi-group ordinary differential equations
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in final size)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @param times optional argument for times at which the solution is to be calculated; if NA (the
#' default) the solution will be computed up to the time at which the total number of infectious
#' individuals is sufficiently close to zero (outbreak extinction)
#' @returns vector of final sizes (number of infected over whole outbreak) for each group
#' @examples
#' simodeSIR(transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
#' popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#' @export
simodeSIR <- function(transmrates, recoveryrate, popsize, initR, initI, initV, times = NA) {

  betaoverNj <- t(t(transmrates) / popsize)

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)

  names(y0) <- c(paste0("S", 1:length(popsize)),
                 paste0("I", 1:length(popsize)),
                 paste0("R", 1:length(popsize)))

  parms <- c(betaoverNj, recoveryrate)
  if(is.na(times)){
    tm <- seq(0, 10000 / recoveryrate, len = 10000)
    rootfun <- function(t, y, parms) sum(y[(length(popsize) + 1):(length(popsize) * 2)]) - sqrt(.Machine$double.eps)
    sim <- deSolve::ode(y0, tm, odeSIR, parms, rootfun = rootfun, method = "lsodar")
  }else{
    sim <- deSolve::ode(y0, times, odeSIR, parms)
  }
  sim
}
