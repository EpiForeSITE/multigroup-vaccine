eventsim <- function(n, time, state, par, events){
  out <- vector("list", n)
  for(j in seq_len(n)){
    outssa <- GillespieSSA2::ssa(
      initial_state = state,
      reactions = events,
      params = par,
      final_time = time,
      method = GillespieSSA2::ssa_exact()
    )
    out[[j]] <- cbind(sim = j, time = outssa["time"]$time, outssa["state"]$state)
  }
  do.call(rbind, out)
}
