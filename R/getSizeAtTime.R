#' Calculate outbreak size at a given time
#' @param time the time at which to calculate the outbreak size
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @returns a list with totalSize (total cumulative infections) and activeSize (total currently infected) in each group at the specified time
#' @export
getSizeAtTime <- function(time, transmrates, recoveryrate, popsize, initR, initI, initV) {

  betaoverNj <- t(t(transmrates) / popsize)

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)
  parms <- c(betaoverNj, recoveryrate)
  times <- seq(0, time, len = 1000)

  sim <- deSolve::ode(y0, times, odeSIR, parms)
  Isim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) + 1):(length(popsize) * 2)])
  Rsim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) * 2 + 1):(length(popsize) * 3)])

  list(totalSize = Isim + Rsim, activeSize = Isim)
}
