finalsize <- function(popsize, R0, contactmatrix, relsusc, reltransm, recoveryrate, initR, initI, initV, method = "ODE", nsims = 1) {

  transmmatrix <- transmissionRates(R0, 1 / recoveryrate, relsusc * t(reltransm * t(contactmatrix)))

  if(method == "ODE")
    return(getFinalSizeODE(transmmatrix, recoveryrate, popsize, initR, initI, initV))

  if(method == "analytic")
    return(getFinalSizeAnalytic(transmmatrix, recoveryrate, popsize, initR, initI, initV))

}
