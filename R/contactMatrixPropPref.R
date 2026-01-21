#' Calculate group contact matrix with proportional mixing and preferential mixing within group
#' @param popsize population size of each group
#' @param contactrate overall contact rate of each group
#' @param ingroup fraction of each group's contacts that are exclusively in-group
#' @returns a square matrix with the contact rate of each group (row) with members of each
#' other group (column)
#' @examples
#' contactMatrixPropPref(popsize = c(100, 150, 200), contactrate = c(1.1, 1, 0.9),
#' ingroup = c(0.2, 0.25, 0.22))
#' @export
contactMatrixPropPref <- function(popsize, contactrate, ingroup) {
  f <- (1 - ingroup) * contactrate * popsize
  contactmatrix <- contactrate * (diag(ingroup) + outer((1 - ingroup), f / sum(f)))
  contactmatrix
}
