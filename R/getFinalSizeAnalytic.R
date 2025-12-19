#' Calculate final size of outbreak: the total number of infections in each group,
#' by solving the analytic final size equation
#' @param Rinit initial number already infected, recovered, and immune in each group
#' @param Iinit initial number actively infectious in each group
#' @param Vinit initial number vaccinated and immunized in each group
#' @param N population size of each group
#' @param R0 overall basic reproduction number
#' @param a relative overall contact rate of each group
#' @param eps fraction of each group's contacts that exclusively within-group
#' @param q relative susceptibility to infection per contact of each group
#' @export
getFinalSizeAnalytic <- function(Rinit, Iinit, Vinit, N, R0, a, eps, q) {
  if (sum(Iinit) == 0)
    Iinit <- N / sum(N)

  Sinit <- N - Rinit - Iinit - Vinit

  cij <- contactMatrixPropPref(N, a, eps)
  transmMatrix <- q * cij
  R0i <- R0 / eigen(transmMatrix)$values[1]

  Zrhs <- function(Z)
    c(Sinit * (1 - exp(-R0i * transmMatrix %*% ((Z + Iinit) / N))))

  #Zrhs <- function(Z)
  #  c(Sinit * (1 - exp(-R0i * cij %*% ((Z + Iinit) / N))))

  optfn <- function(x)
    ifelse(all(x > 0), max(abs(x - Zrhs(x))), Inf)

  optVal <- Inf
  while (optVal > 0.1) {
    opt <- stats::optim((0.01 + 0.98 * stats::runif(length(N))) * N, optfn)
    optVal <- opt$value
  }
  opt$par + Iinit + Rinit
}
