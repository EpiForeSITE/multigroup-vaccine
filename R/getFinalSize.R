#' Calculate final size of outbreak: the total number of infections in each group
#' @param vacTime time after first case at which all vaccinations are delivered
#' @param vacPortion fraction of each population vaccinated
#' @param popSize size of each population
#' @param R0 overall basic reproduction number
#' @param recoveryRate inverse of mean infectious period
#'     (same time units as vacTime)
#' @param relContact relative overall contact rate of each group
#' @param contactWithinGroup fraction of each group's contacts that are
#'    in-group vs out-group
#' @param relSusc relative susceptibility to infection per contact of each group
#' @export
getFinalSize <- function(vacTime,
                         vacPortion,
                         popSize,
                         R0,
                         recoveryRate,
                         relContact,
                         contactWithinGroup,
                         relSusc) {

  Isim1 <- popSize / sum(popSize)
  Rsim1 <- rep(0, length(popSize))
  Vsim1 <- rep(0, length(popSize))

  incontact <- contactWithinGroup
  relcontact <- relContact
  relsusc <- relSusc
  contactmatrix <- contactMatrixPropPref(popSize, relcontact, incontact)
  reltransm <- relsusc * contactmatrix
  transmrates <- transmissionRates(R0, 1 / recoveryRate, reltransm)

  if (vacTime > 0) {
    sizeAtVacTime <- getSizeAtTime(vacTime, transmrates, recoveryRate, popSize, Rsim1, Isim1, Vsim1)
    Isim1 <- sizeAtVacTime$activeSize
    Rsim1 <- sizeAtVacTime$totalSize - Isim1
  }

  getFinalSizeAnalytic(
    transmrates = transmrates,
    recoveryrate = recoveryRate,
    popsize = popSize,
    initR = Rsim1,
    initI = Isim1,
    initV = popSize * vacPortion
  )
}
