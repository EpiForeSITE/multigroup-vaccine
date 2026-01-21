#' Calculate a contact matrix for age groups based on Polymod contact survey data
#'
#' @param agelims minimum age in years for each age group. The maximum valid
#'   age limit is 90, as the socialmixr contact_matrix function supports ages
#'   up to 90. Age limits greater than 90 will be replaced with 90 and a
#'   warning will be issued.
#' @param agepops population size of each group, defaulting to demography of
#'   Polymod survey population. If provided, must match the length of the
#'   age groups defined by `agelims` (after any adjustments for exceeding
#'   the 90-year limit).
#' @return A symmetric contact matrix with row and column names indicating
#'   the age groups.
#' @details The socialmixr contact_matrix function supports age limits up to 90.
#'   Any age limits above 90 will be adjusted to 90 with a warning, and the
#'   corresponding populations will be aggregated into a single "90+" group.
#' @examples
#' #Default population distribution uses population data from POLYMOD survey locations:
#' contactMatrixPolymod(agelims = c(0, 5, 18))
#' #Specifying the age distribution will lead to an adjusted version:
#' contactMatrixPolymod(agelims = c(0, 5, 18), agepops = c(500, 1300, 8200))
#' @export
contactMatrixPolymod <- function(agelims, agepops = NULL) {

  # Maximum age limit supported by socialmixr contact_matrix
  max_age_limit <- 90L

  # Check if any age limits exceed the maximum
  if (any(agelims > max_age_limit)) {
    exceeding <- agelims[agelims > max_age_limit]
    warning(
      "Age limits greater than ", max_age_limit, " are not supported by the ",
      "Polymod survey data. The following age limits were replaced with ",
      max_age_limit, ": ", paste(exceeding, collapse = ", "), ". ",
      "Corresponding populations have been aggregated into a single '",
      max_age_limit, "+' group.",
      call. = FALSE
    )

    # Find indices of age limits to keep (those <= max_age_limit)
    keep_idx <- which(agelims <= max_age_limit)

    # If no age limits include max_age_limit, we need to add it
    if (!max_age_limit %in% agelims) {
      new_agelims <- c(agelims[keep_idx], max_age_limit)
    } else {
      new_agelims <- agelims[keep_idx]
    }

    # Aggregate populations if agepops is provided
    if (!is.null(agepops)) {
      # Indices where agelims > max_age_limit
      exceeding_idx <- which(agelims > max_age_limit)

      if (!max_age_limit %in% agelims) {
        # Keep populations for age limits < max_age_limit
        # Aggregate all populations from exceeding limits into the new 90+ group
        new_agepops <- c(
          agepops[keep_idx],
          sum(agepops[exceeding_idx])
        )
      } else {
        # max_age_limit is already in agelims, aggregate exceeding into that group
        max_idx <- which(agelims == max_age_limit)
        new_agepops <- agepops[keep_idx]
        new_agepops[length(new_agepops)] <- sum(agepops[c(max_idx, exceeding_idx)])
      }
      agepops <- new_agepops
    }

    agelims <- new_agelims
  }

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
