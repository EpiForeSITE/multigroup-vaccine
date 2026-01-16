#' Calculate a contact matrix for age groups and schools
#' @param agelims minimum age in years for each age group
#' @param agepops population size of each age group
#' @param schoolagegroups index of the age group covered by each school
#' @param schoolpops population size of each school
#' @param schportion portion of within-age-group contacts that are exclusively within school
#' @examples
#' contactMatrixAgeSchool(agelims = c(0, 5, 18), agepops = c(500, 1300, 8200), schoolagegroups = c(2, 2), schoolpops = c(600, 700), schportion = 0.7)
#' @export
contactMatrixAgeSchool <- function(agelims, agepops, schoolagegroups, schoolpops, schportion) {
  cmp <- contactMatrixPolymod(agelims, agepops)
  ngrps <- length(agepops) + length(schoolpops) - length(unique(schoolagegroups))
  cmps <- matrix(0, ngrps, ngrps)
  npre <- min(schoolagegroups) - 1
  npost <- length(agepops) - max(schoolagegroups)
  nsch <- length(schoolpops)
  ipre <- 1:npre
  ipost <- (ngrps-npost+1):ngrps
  isch <- (npre+1):(npre+nsch)
  nm <- colnames(cmp)
  grpnames <- c(nm[1:npre], paste0(nm[schoolagegroups],"s",1:length(schoolagegroups)), nm[(nrow(cmp)-npost+1):nrow(cmp)])
  rownames(cmps) <- colnames(cmps) <- grpnames
  cmps[ipre, ipre] <- cmp[1:npre, 1:npre]
  cmps[ipost, ipost] <- cmp[(nrow(cmp)-npost+1):nrow(cmp), (nrow(cmp)-npost+1):nrow(cmp)]
  cmps[ipre, ipost] <- cmp[1:npre, (nrow(cmp)-npost+1):nrow(cmp)]
  cmps[ipost, ipre] <- cmp[(nrow(cmp)-npost+1):nrow(cmp), 1:npre]
  sag <- unique(schoolagegroups)
  for(s in sag){
    inds <- which(schoolagegroups == s)
    nums <- length(inds)
    for(i in 1:npre){
      cmps[i, npre + inds] <- cmp[i, s] * schoolpops[inds] / agepops[s]
      cmps[npre + inds, i] <- cmp[s, i]
    }
    for(i in 1:npost){
      cmps[nrow(cmps) - i + 1, npre + inds] <- cmp[nrow(cmp) - i + 1, s] * schoolpops[inds] / agepops[s]
      cmps[npre + inds, nrow(cmps)-i+1] <- cmp[s, nrow(cmp)-i+1]
    }
    cmps[npre + inds, npre + inds] <- contactMatrixPropPref(schoolpops[inds], rep(cmp[s, s], nums), rep(schportion, nums))

    if(length(sag) > 1){
      for(ss in sag[sag != s]){
        for(j in which(schoolagegroups == ss)){
          cmps[npre + inds, npre + j] <- cmp[s, ss] * schoolpops[j] / agepops[ss]
        }
      }
    }
  }
  cmps
}
