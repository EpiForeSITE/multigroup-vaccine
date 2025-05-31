#' Estimate the distribution of final outbreak sizes by group using stochastic simulations of multi-group model
#' @param n the number of simulations to run
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @returns a matrix with the final number infected from each group (column) in each simulation (row)
#' @export
getFinalSizeDist <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- t(t(transmrates) / popsize)
  initS <- popsize - initR - initV
  Rtally <- matrix(0, n, g)
  for (r in 1:n) {
    I <- initI
    S <- initS
    R <- initR

    while (sum(I) > 0) {
      tr <- rowSums(outer(S, I) * betaoverNj)
      rr <- I * recoveryrate

      event <- sample(e, 1, prob = c(tr, rr))

      if (event > g) {
        I[event - g] <- I[event - g] - 1
        R[event - g] <- R[event - g] + 1
      } else {
        S[event] <- S[event] - 1
        I[event] <- I[event] + 1
      }
    }
    Rtally[r, ] <- R
  }
  Rtally
}
