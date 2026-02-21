simOutbreakDistGSSA <- function(n, transmrates, recoveryrate, popsize, initR, initI, initV) {
  g <- length(popsize) # number of groups
  betaoverNj <- t(t(transmrates) / popsize)

  params <- c(betaoverNj, recoveryrate)
  names(params) <- c(paste0("b", rep(seq_len(g), g), rep(seq_len(g), each = g)), "gamma")

  initS <- popsize - initR - initV
  initial_state <- c(initS, initI, initR)
  names(initial_state) <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))

  reactions <- unlist(lapply(
    seq_len(g),
    function(i) {
      Si <- paste0("S", i)
      Ii <- paste0("I", i)
      Ri <- paste0("R", i)
      list(
        reaction(
          propensity = paste0("(", paste(paste0("b", i, seq_len(g), " * I", seq_len(g)), collapse = " + "),")", " * S", i),
          effect = setNames(c(-1, +1), c(Si, Ii)),
          name = paste0("infection", i)
        ),
        reaction(
          propensity = paste0("gamma * ", Ii),
          effect = setNames(c(-1, +1), c(Ii, Ri)),
          name = paste0("recovery", i)
        )
      )
    }
  ), recursive = FALSE)

  cr <- compile_reactions(reactions, state_ids = names(initial_state), params = params)

  out <- vector("list", n)
  for(j in seq_len(n)){
    outssa <- ssa(
      initial_state = initial_state,
      reactions = cr,
      params = params,
      final_time = 100,
      method = ssa_exact()
    )
    out[[j]] <- cbind(sim = j, time = outssa["time"]$time, outssa["state"]$state)
  }
  z <- matrix(unlist(out), ncol = g * 3 + 2)
}
