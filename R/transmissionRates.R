#' Calculate transmission rate matrix for multi-group model with specified R0
#' @param R0 overall basic reproduction number
#' @param meaninf mean duration of infectious period
#' @param reltransm matrix with relative transmission rates, from column-group to row-group
#' @returns a matrix of transmission rates to (row) and from (column) each group,
#'   in same time units as meaninf
#' @examples
#' transmissionRates(R0 = 15, meaninf = 7,
#'   reltransm = rbind(c(1, 0.5, 0.9), c(0.3, 1.9, 1), c(0.3, 0.6, 2.8)))
#' @export
transmissionRates <- function(R0, meaninf, reltransm) {
  reltransm * R0 / eigen(reltransm)$values[1] / meaninf
}
