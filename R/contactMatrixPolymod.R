contactMatrixPolymod <- function(agelims, agepops) {

  grpnames <- c(
    paste0("under", agelims[2]),
    paste0(agelims[2:(length(agelims) - 1)], "to", agelims[3:length(agelims)] - 1),
    paste0(agelims[length(agelims)], "+")
  )

  #data(polymod)
  suppressWarnings(
    cm <- socialmixr::contact_matrix(
      polymod,
      age.limits = agelims,
      symmetric = TRUE,
      missing.participant.age = "remove",
      missing.contact.age = "remove"
    )
  )

  nj <- cm$demography$proportion
  mij <- t(t(cm$matrix) / nj * (agepops / sum(agepops)))
  rownames(mij) <- grpnames
  colnames(mij) <- grpnames
  mij
}
