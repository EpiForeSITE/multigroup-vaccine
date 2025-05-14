#' Calculate transmission rate matrix for multigroup model with specified R0
#' @param R0 overall basic reproduction number
#' @param meaninf mean duration of infectious period
#' @param popsize population size of each group
#' @param incontact fraction of each group's contacts that are exclusively within group
#' @param relcontact relative overall contact rates of each group
#' @param relsusc relative susceptibility to infection per contact of each group
#' @returns a matrix of transmission rates to (row) and from (column) each group
#' @examples
#' transmissionRates(R0 = 15, meaninf = 7, popsize = c(100, 200, 300), incontact = c(0.3, 0.4, 0.45), relcontact = c(1, 1.1, 1.4), relsusc = c(1, 1.2, 1.1))
#' @export
transmissionRates <- function(R0, meaninf, popsize, incontact, relcontact, relsusc) {
  f <- (1 - incontact) * relcontact * popsize
  Bij <- relcontact * relsusc * (diag(incontact) + outer((1 - incontact), f / sum(f)))
  betaij <- Bij * R0 / eigen(Bij)$values[1] / meaninf
  betaij
}
