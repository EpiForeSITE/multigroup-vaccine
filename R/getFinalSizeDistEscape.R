#' Estimate the distribution of final outbreak sizes by group using a hybrid model: stochastic simulations
#' for smaller-sized outbreaks and deterministic ordinary differential equation model for "escaped" outbreaks
#' @param n the number of simulations to run
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @returns a matrix with the final number infected from each group (column) in each simulation (row)
#' @examples
#' getFinalSizeDistEscape(n = 10, transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
#' popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#' @export
getFinalSizeDistEscape <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  fsODE <- round(getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV))

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

      logprobend <- sum(I) * log(recoveryrate / sum(tr))

      if (logprobend < -40) {
        R <- fsODE
        I <- rep(0, g)
      } else {

        event <- sample(e, 1, prob = c(tr, rr))

        if (event > g) {
          I[event - g] <- I[event - g] - 1
          R[event - g] <- R[event - g] + 1
        } else {
          S[event] <- S[event] - 1
          I[event] <- I[event] + 1
        }
      }
    }
    Rtally[r, ] <- R
  }
  Rtally
}
