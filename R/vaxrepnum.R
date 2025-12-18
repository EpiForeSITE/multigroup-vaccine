#' Calculate reproduction number for a multigroup model with a given state of
#' vaccination and immunity
#' @param meaninf mean infectious period with same time units as trmat
#' @param popsize the population size of each group
#' @param initR initial number of each group already infected and immune
#' @param initV initial number of each group vaccinated
#' @param vaxeff effectiveness (0 to 1) of vaccine in producing immunity to infection
#' @export
vaxrepnum <- function(meaninf, popsize, trmat, initR, initV, vaxeff) {

  betaij <- trmat * (1 - (initR + initV * vaxeff) / popsize)

  eigen(betaij)$values[1] * meaninf
}
