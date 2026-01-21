#' Calculate final outbreak size or distribution of a multigroup transmission model for a given basic
#' reproduction number, contact/transmission assumptions, and initial conditions
#' @param popsize the population size of each group
#' @param R0 the basic reproduction number
#' @param contactmatrix matrix of group-to-group contact rates
#' @param relsusc relative susceptibility to infection per contact of each group
#' @param reltransm relative transmissibility per contact of each group
#' @param initR initial number of each group already infected and removed (included in size result)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @param method the method of final size calculation or simulation to use
#' @param nsims the number of simulations to run for stochastic methods
#' @returns a vector (nsims = 1) or matrix (nsims > 1) with the final number infected from each group (column) in each simulation (row)
#' @examples
#' popsize <- c(800, 200)
#' R0 <- 2
#' contactmatrix <- contactMatrixPropPref(popsize = popsize, contactrate = c(1, 1),
#' ingroup = c(0.2, 0.2))
#' relsusc <- c(1, 1)
#' reltransm <- c(1, 1)
#' initR <- c(0, 0)
#' initI <- c(1, 0)
#' initV <- 0.2 * popsize
#' # Default method "ODE" numerical solves ordinary differential equations until infectious count
#' # is close to 0
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV)
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "analytic")
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "stochastic", nsims = 10)
#' # All "escaped" outbreaks set to deterministic final size:
#' finalsize(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV,
#' method = "hybrid", nsims = 10)
#' @export
finalsize <- function(popsize, R0, contactmatrix, relsusc, reltransm, initR, initI, initV, method = "ODE", nsims = 1) {

  #Use generic recovery rate; final size is independent of recovery rate when R0 is specified
  recoveryrate <- 1

  transmmatrix <- transmissionRates(R0, 1 / recoveryrate, relsusc * t(reltransm * t(contactmatrix)))

  if(method == "ODE"){
    return(getFinalSizeODE(transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if(method == "analytic"){
    return(getFinalSizeAnalytic(transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if(method == "stochastic"){
    return(getFinalSizeDist(nsims, transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  if(method == "hybrid"){
    return(getFinalSizeDistEscape(nsims, transmmatrix, recoveryrate, popsize, initR, initI, initV))
  }

  stop("Unknown method")
}
