eventsimSIR <- function(transmrates, recoveryrate, popsize, initR, initI, initV, nsims = 1, time = NA, interval = 0) {
  g <- length(popsize) # number of groups
  betaoverNj <- t(t(transmrates) / popsize)

  params <- c(betaoverNj, recoveryrate)
  names(params) <- c(paste0("b", rep(seq_len(g), g), rep(seq_len(g), each = g)), "gamma")

  initS <- popsize - initR - initI - initV
  initial_state <- c(initS, initI, initR)
  names(initial_state) <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))

  sir_ssa_cpp(initial_state, betaoverNj, recoveryrate, time)
  #eventsim(n = nsims,
  #         time = time,
  #         state = initial_state,
  #         par = params,
  #         events = evntSIR[[g]],
  #         interval = interval)
}
