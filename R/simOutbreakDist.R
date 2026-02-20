simOutbreakDist <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- t(t(transmrates) / popsize)
  initS <- popsize - initR - initV
  nI <- sum(initI)
  Rtally <- matrix(0, n, g)
  ind <- stateind <- 1
  tsim <- gsim <- rep(NA, n * nI * 10)
  statesim <- matrix(NA, n * nI * 10, g * 3 + 2)
  gsimInit <- rep(which(initI > 0), initI[initI > 0])
  for (r in 1:n) {
    I <- initI
    S <- initS
    R <- initR

    tm <- 0
    while(ind + nI - 1 > length(tsim)){
      length(tsim) <- length(gsim) <- length(tsim) * 2
    }
    tsim[ind:(ind + nI - 1)] <- 0
    gsim[ind:(ind + nI - 1)] <- gsimInit
    ind <- ind + nI

    if(stateind > nrow(statesim)){
      statesim <- rbind(statesim, matrix(NA, nrow(statesim), g * 3 + 2))
    }
    statesim[stateind, ] <- c(r, tm, S, I, R)
    stateind <- stateind + 1

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
      if(stateind > nrow(statesim)){
        statesim <- rbind(statesim, matrix(NA, nrow(statesim), g * 3 + 2))
      }
      statesim[stateind, ] <- c(r, tm, S, I, R)
      stateind <- stateind + 1
    }
    Rtally[r, ] <- R
  }

  x <- rep(1:n, rowSums(Rtally))
  y <- tsim[!is.na(tsim)]
  z <- gsim[!is.na(tsim)]

  statesim <- statesim[complete.cases(statesim), ]
  colnames(statesim) <- c("sim", "time", paste0("S", 1:g), paste0("I", 1:g), paste0("R", 1:g))

  list(total = Rtally, inftime = cbind(sim = x, inftime = y, group = z), statesim = statesim)
}
