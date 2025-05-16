getFinalSizeSim <- function(R0, recoveryRate, popsize, initR, initI, initV, incontact, relcontact, relsusc) {

  beta <- transmissionRates(R0, 1 / recoveryRate, popsize, incontact, relcontact, relsusc)
  betaoverNj <- t(t(beta) / popsize)

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)
  parms <- c(betaoverNj, recoveryRate)
  times <- seq(0, 1000 / recoveryRate, len = 1000)
  rootfun <- function(t, y, parms) sum(y[(length(popsize) + 1):(length(popsize) * 2)]) - sqrt(.Machine$double.eps)

  sim <- deSolve::ode(y0, times, odeSIR, parms, rootfun = rootfun, method = "lsodar")

  Isim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) + 1):(length(popsize) * 2)])
  Rsim <- as.numeric(sim[, -1][nrow(sim), (length(popsize) * 2 + 1):(length(popsize) * 3)])

  list(totalSize = Isim + Rsim, activeSize = Isim)
}
