simodeSIR <- function(transmrates, recoveryrate, popsize, initR, initI, initV, times = NA) {

  betaoverNj <- t(t(transmrates) / popsize)

  initS <- popsize - initR - initI - initV

  y0 <- c(initS, initI, initR)

  names(y0) <- c(paste0("S", 1:length(popsize)),
                 paste0("I", 1:length(popsize)),
                 paste0("R", 1:length(popsize)))

  parms <- c(betaoverNj, recoveryrate)
  if(is.na(times)){
    tm <- seq(0, 10000 / recoveryrate, len = 10000)
    rootfun <- function(t, y, parms) sum(y[(length(popsize) + 1):(length(popsize) * 2)]) - sqrt(.Machine$double.eps)
    sim <- deSolve::ode(y0, tm, odeSIR, parms, rootfun = rootfun, method = "lsodar")
  }else{
    sim <- deSolve::ode(y0, tm, odeSIR, parms)
  }
  sim
}
