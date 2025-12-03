#' Calculate group contact matrix with proportional mixing and preferential mixing within group
#' @param popsize population size of each group
#' @param contactrate overall contact rate of each group
#' @param ingroup fraction of each group's contacts that are exclusively in-group
#' @export
contactMatrixPropPref <- function(popsize, contactrate, ingroup) {
  f <- (1 - ingroup) * contactrate * popsize
  contactmatrix <- contactrate * (diag(ingroup) + outer((1 - ingroup), f / sum(f)))
  contactmatrix
}
