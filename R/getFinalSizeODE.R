#' Calculate outbreak final size, the total number of infections in each group, by numerically
#' solving the multi-group ordinary differential equation
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in final size)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @export
getFinalSizeODE <- function(transmrates, recoveryrate, popsize, initR, initI, initV) {

  betaoverNj <- t(t(transmrates) / popsize)

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)
  parms <- c(betaoverNj, recoveryrate)
  times <- seq(0, 1000 / recoveryrate, len = 1000)
  rootfun <- function(t, y, parms) sum(y[(length(popsize) + 1):(length(popsize) * 2)]) - sqrt(.Machine$double.eps)

  sim <- deSolve::ode(y0, times, odeSIR, parms, rootfun = rootfun, method = "lsodar")

  Isim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) + 1):(length(popsize) * 2)])
  Rsim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) * 2 + 1):(length(popsize) * 3)])

  list(totalSize = Isim + Rsim, activeSize = Isim)
}
