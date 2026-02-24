simOutbreakDistGSSA <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  betaoverNj <- t(t(transmrates) / popsize)

  params <- c(betaoverNj, recoveryrate)
  names(params) <- c(paste0("b", rep(seq_len(g), g), rep(seq_len(g), each = g)), "gamma")

  initS <- popsize - initR - initV
  initial_state <- c(initS, initI, initR)
  names(initial_state) <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))

  out <- vector("list", n)
  for(j in seq_len(n)){
    outssa <- GillespieSSA2::ssa(
      initial_state = initial_state,
      reactions = cr,
      params = params,
      final_time = 1000/recoveryrate,
      method = ssa_exact()
    )
    out[[j]] <- cbind(sim = j, time = outssa["time"]$time, outssa["state"]$state)
  }
  do.call(rbind, out)
}
