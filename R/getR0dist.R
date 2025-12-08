#' TODO: Add documentation and @keywords internal flag
#' DETERMINE IF THIS IS UNUSED AND CAN BE DELETED
#' @keywords internal
getR0dist <- function(n, popsize, recoveryrate, transmrates, initV) {
  g <- length(popsize) # number of groups
  e <- g * 2           # number of distinct events
  betaoverNj <- t(t(transmrates) / popsize)
  initS <- popsize - initV
  transmissions <- rep(0, n)
  for (r in 1:n) {
    I <- rep(0, g)
    I[sample(g, 1, prob = popsize)] <- 1
    S <- initS

    tr <- rowSums(outer(S, I) * betaoverNj)
    rr <- I * recoveryrate
    while (sum(I) > 0) {

      event <- sample(e, 1, prob = c(tr, rr))

      if (event > g) {
        I[event - g] <- I[event - g] - 1
      } else {
        transmissions[r] <- transmissions[r] + 1
      }
    }
  }
  transmissions
}
