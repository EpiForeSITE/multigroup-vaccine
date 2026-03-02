#' Estimate the distribution of final outbreak sizes by group using stochastic simulations of multi-group model
#' @param n the number of simulations to run
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @returns a matrix with the final number infected from each group (column) in each simulation (row)
#' @examples
#' getFinalSizeDist(n = 10, transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
#' popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#' @export
getFinalSizeDist <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- c(t(t(transmrates) / popsize))
  initS <- popsize - initR - initV
  init <- c(initS, initI, initR)
  names(init) <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))
  Rtally <- matrix(0, n, g)
  for (r in 1:n) {
    fs <- sir_finalsize_cpp(init, betaoverNj, recoveryrate)
    Rtally[r, ] <- fs[(2*g+1):(3*g)]
  }
  Rtally
}

#' @useDynLib multigroup.vaccine, .registration = TRUE
#' @importFrom Rcpp evalCpp
NULL
