# TODO: Add documentation and @keywords internal flag unless we want it to be exported
#' @keywords internal
vaxrepnum <- function(meaninf, popsize, trmat, initR, initV, vaxeff) {

  betaij <- trmat * (1 - (initR + initV * vaxeff) / popsize)

  eigen(betaij)$values[1] * meaninf
}
