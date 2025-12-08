# TODO: Add documentation and @internal flag unless we want it to be exported
#' @internal
vaxrepnum <- function(meaninf, popsize, trmat, initR, initV, vaxeff) {

  betaij <- trmat * (1 - (initR + initV * vaxeff) / popsize)

  eigen(betaij)$values[1] * meaninf
}
