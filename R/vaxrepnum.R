#' Calculate reproduction number for a multigroup model with a given state of
#' vaccination and immunity
#' @param meaninf mean infectious period with same time units as trmat
#' @param popsize the population size of each group
#' @param trmat matrix of group-to-group (column-to-row) transmission rates
#' @param initR initial number of each group already infected and immune
#' @param initV initial number of each group vaccinated
#' @param vaxeff effectiveness (0 to 1) of vaccine in producing immunity to infection
#' @returns the reproduction number
#' @examples
#' meaninf <- 7
#' popsize <- c(200, 800)
#' initR <- c(0, 0)
#' initV <- c(0, 0)
#' vaxeff <- 1
#' trmat <- matrix(c(0.63, 0.31, 0.19, 1.2), 2, 2)
#' vaxrepnum(meaninf, popsize, trmat, initR, initV, vaxeff)
#' vaxrepnum(meaninf, popsize, trmat, initR, initV = c(160, 750), vaxeff)
#' @export
vaxrepnum <- function(meaninf, popsize, trmat, initR, initV, vaxeff) {

  betaij <- trmat * (1 - (initR + initV * vaxeff) / popsize)

  eigen(betaij)$values[1] * meaninf
}
