#' Estimate the distribution of final outbreak sizes by group using stochastic simulations of multi-group model
#' @param n the number of simulations to run
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed for each simulation (included in final size result); if a matrix, row i is used for simulation i
#' @param initI initial number of each group infectious for each simulation; if a matrix, row i is used for simulation i
#' @param initV initial number of each group immune due to vaccination or prior-outbreak infection for each simulation (not included in final size result); if a matrix, row i is used for simulation i
#' @returns a matrix with the final number infected from each group (column) in each simulation (row)
#' @examples
#' getFinalSizeDist(n = 10, transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
#' popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#' @export
getFinalSizeDist <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  if(nrow(transmrates) != g || ncol(transmrates) != g){
    stop("dimensions of transmrates inconsistent with other arguments")
  }
  if(length(initR) == g){
    initialR <- matrix(rep(initR, n), n, byrow = TRUE)
  }else{
    initialR <- initR
  }
  if(length(initI) == g){
    initialI <- matrix(rep(initI, n), n, byrow = TRUE)
  }else{
    initialI <- initI
  }
  if(length(initV) == g){
    initialV <- matrix(rep(initV, n), n, byrow = TRUE)
  }else{
    initialV <- initV
  }
  if(nrow(initialR) != n || ncol(initialR) != g){
    stop("dimensions of initR inconsistent with other arguments")
  }
  if(nrow(initialI) != n || ncol(initialI) != g){
    stop("dimensions of initI inconsistent with other arguments")
  }
  if(nrow(initialV) != n || ncol(initialV) != g){
    stop("dimensions of initV inconsistent with other arguments")
  }

  betaoverNj <- c(t(t(transmrates) / popsize))
  initialS <- matrix(rep(popsize, n), n, byrow = TRUE) - initialR - initialV - initialI
  init <- cbind(initialS, initialI)
  Rtally <- matrix(0, n, g)
  for (r in 1:n) {
    fs <- sir_finalsize_cpp(init[r, ], betaoverNj, recoveryrate)
    Rtally[r, ] <- initialS[r, ] - fs[1:g] + initialI[r, ] + initialR[r, ]
  }
  Rtally
}

#' @useDynLib multigroup.vaccine, .registration = TRUE
#' @importFrom Rcpp evalCpp
NULL
