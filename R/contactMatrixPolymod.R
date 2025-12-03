#' Calculate a contact matrix for age groups based on Polymod contact survey data
#' @param agelims minimum age in years for each age group
#' @param agepops population size of each group, defaulting to demography of Polymod survey population
#' @export
contactMatrixPolymod <- function(agelims, agepops = NULL) {

  grpnames <- c(
    paste0("under", agelims[2]),
    paste0(agelims[2:(length(agelims) - 1)], "to", agelims[3:length(agelims)] - 1),
    paste0(agelims[length(agelims)], "+")
  )

  #data(polymod)
  suppressWarnings(
    cm <- socialmixr::contact_matrix(
      socialmixr::polymod,
      age.limits = agelims,
      symmetric = TRUE,
      missing.participant.age = "remove",
      missing.contact.age = "remove"
    )
  )

  if(is.null(agepops)){
    mij <- cm$matrix
  }else{
    nj <- cm$demography$proportion
    mij <- t(t(cm$matrix) / nj * (agepops / sum(agepops)))
  }

  rownames(mij) <- grpnames
  colnames(mij) <- grpnames
  mij
}
