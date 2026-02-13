simStochasticOutbreak <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- t(t(transmrates) / popsize)
  initS <- popsize - initR - initV
  nI <- sum(initI)
  Rtally <- matrix(0, n, g)
  ind <- 1
  tsim <- gsim <- rep(NA, n * nI * 10)
  gsimInit <- rep(which(initI > 0), initI[initI > 0])
  for (r in 1:n) {
    I <- initI
    S <- initS
    R <- initR

    tm <- 0
    if(ind + nI - 1 > length(tsim)){
      length(tsim) <- length(gsim) <- length(tsim) * 2
    }
    tsim[ind:(ind + nI - 1)] <- 0
    gsim[ind:(ind + nI - 1)] <- gsimInit
    ind <- ind + nI

    while (sum(I) > 0) {
      tr <- rowSums(outer(S, I) * betaoverNj)
      rr <- I * recoveryrate
      rates <- c(tr, rr)

      event <- sample(e, 1, prob = rates)
      tm <- tm + rexp(1, sum(rates))

      if (event > g) {
        I[event - g] <- I[event - g] - 1
        R[event - g] <- R[event - g] + 1
      } else {
        S[event] <- S[event] - 1
        I[event] <- I[event] + 1

        tsim[ind] <- tm
        gsim[ind] <- event
        ind <- ind + 1
        if(ind > length(tsim)){
          length(tsim) <- length(gsim) <- length(tsim) * 2
        }
      }
    }
    Rtally[r, ] <- R
  }

  x <- rep(1:n, rowSums(Rtally))
  y <- tsim[!is.na(tsim)]
  z <- gsim[!is.na(tsim)]

  list(total = Rtally, inftime = cbind(sim = x, inftime = y, group = z))
  #xc <- cumsum(c(1, x))
  #max_len <- max(x)
  #last_vals <- y[cumsum(x)]
  #mp <- matrix(last_vals, nrow = n, ncol = max_len, byrow = FALSE)
  #row_idx <- rep(1:n, times = x)
  #col_idx <- sequence(x)
  #mp[cbind(row_idx, col_idx)] <- y
  #mp
}
