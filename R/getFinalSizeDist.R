getFinalSizeDist <- function(n, popsize, recoveryrate, transmrates, initV){
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- t(t(transmrates) / popsize)
  initS <- popsize - initV
  Rtally <- matrix(0, n, g)
  for (r in 1:n){
    I <- rep(0, g)
    I[sample(g, 1, prob = initS)] <- 1
    S <- initS - I
    R <- rep(0, g)

    while (sum(I) > 0){
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
