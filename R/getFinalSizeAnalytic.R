#' Calculate final size of outbreak: the total number of infections in each group,
#' by solving the analytic final size equation
#' @param transmrates matrix of group-to-group (column-to-row) transmission rates
#' @param recoveryrate inverse of mean infectious period
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and removed (included in final size)
#' @param initI initial number of each group infectious
#' @param initV initial number of each group vaccinated
#' @returns vector of final sizes (number of infected over whole outbreak) for each group
#' @examples
#' getFinalSizeAnalytic(transmrates = matrix(0.2, 2 ,2), recoveryrate = 0.3,
#' popsize = c(100, 150), initR = c(0, 0), initI = c(0, 1), initV = c(10, 10))
#' @export
getFinalSizeAnalytic <- function(transmrates, recoveryrate, popsize, initR, initI, initV) {
  if (sum(initI) == 0)
    initI <- popsize / sum(popsize)

  initS <- popsize - initR - initI - initV

  R0mat <- transmrates / recoveryrate

  Zrhs <- function(Z)
    c(initS * (1 - exp(-R0mat %*% ((Z + initI) / popsize))))

  optfn <- function(x)
    ifelse(all(x > 0), max(abs(x - Zrhs(x))), Inf)

  optVal <- Inf
  while (optVal > 0.1) {
    opt <- stats::optim((0.01 + 0.98 * stats::runif(length(popsize))) * popsize, optfn)
    optVal <- opt$value
  }
  opt$par + initI + initR
}
