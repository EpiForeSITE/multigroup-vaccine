#' Calculate final size of outbreak: the total number of infections in each group
#' @param vacTime time after first case at which all vaccinations are delivered
#' @param vacPortion fraction of each population vaccinated
#' @param popSize size of each population
#' @param R0 overall basic reproduction number
#' @param recoveryRate inverse of mean infectious period
#'     (same time units as vacTime)
#' @param contactRatio ratio of 2nd group's : 1st group's overall contact rate
#' @param contactWithinGroup fraction of each group's contacts that are
#'    in-group vs out-group
#' @param suscRatio ratio of 2nd group's : 1st group's susceptibility to infection per contact
#' @export
getFinalSize <- function(vacTime,
                         vacPortion,
                         popSize,
                         R0,
                         recoveryRate,
                         contactRatio,
                         contactWithinGroup,
                         suscRatio) {


  Isim1 <- popSize / sum(popSize)
  Rsim1 <- c(0, 0)
  Vsim1 <- c(0, 0)

  incontact <- contactWithinGroup
  relcontact <- c(1, contactRatio)
  relsusc <- c(1, suscRatio)

  if (vacTime > 0) {
    sizeAtVacTime <- getSizeAtTime(vacTime, R0, recoveryRate, popSize, Rsim1, Isim1, Vsim1, incontact, relcontact, relsusc)
    Isim1 <- sizeAtVacTime$activeSize
    Rsim1 <- sizeAtVacTime$totalSize - Isim1
  }

  getFinalSizeAnalytic(
    Rinit = Rsim1,
    Iinit = Isim1,
    Vinit = popSize * vacPortion,
    N = popSize,
    R0 = R0,
    a = c(1, contactRatio),
    eps = contactWithinGroup,
    q = c(1, suscRatio)
  )

}
