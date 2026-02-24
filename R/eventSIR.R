eventSIR <-  function(g){
  params <- rep(1, g^2 + 1)
  names(params) <- c(paste0("b", rep(seq_len(g), g), rep(seq_len(g), each = g)), "gamma")
  state_ids <- c(paste0("S", seq_len(g)), paste0("I", seq_len(g)), paste0("R", seq_len(g)))

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

  compile_reactions(reactions, state_ids = state_ids, params = params)
}
