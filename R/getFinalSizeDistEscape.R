getFinalSizeDistEscape <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  fsODE <- round(getFinalSizeODE(transmrates, recoveryrate, popsize, initR, initI, initV)$totalSize)

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

      if(logprobend < -40) {
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
