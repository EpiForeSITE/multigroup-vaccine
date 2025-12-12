#' ODE system for multi-group SIR model
#' TODO: Add documentation and @keywords internal flag unless we want it to be exported
#' time parameter doesn't seem to be used, can this be removed safely?
#' @keywords internal
odeSIR <- function(time, state, par) {
  ngrp <- length(state) / 3
  S <- state[1:ngrp]
  I <- state[(ngrp + 1):(2 * ngrp)]
  betaoverNj <- matrix(par[1:(ngrp^2)], nrow = ngrp, ncol = ngrp)
  gam <- par[length(par)]

  dS <- -(betaoverNj %*% I) * S
  dI <- (betaoverNj %*% I) * S - gam * I
  dR <- gam * I

  return(list(c(dS, dI, dR)))
}
