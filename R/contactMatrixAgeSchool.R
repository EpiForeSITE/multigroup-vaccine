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
  for(s in unique(schoolagegroups)){
    inds <- which(schoolagegroups == s)
    cmps[1:npre, npre + inds] <- cmp[1:npre, s] * schoolpops[inds] / agepops[s]
    cmps[nrow(cmps)-(1:npost)+1, npre + inds] <- cmp[nrow(cmp)-(1:npost)+1, s] * schoolpops[inds] / agepops[s]
    for(i in 1:npre) cmps[npre + inds, i] <- cmp[s, i]
    for(i in 1:npost) cmps[npre + inds, nrow(cmps)-i+1] <- cmp[s, nrow(cmp)-i+1]
  }

  for(i in isch){
    x <- schoolagegroups[i - npre]
    for(j in isch){
      y <- schoolagegroups[j - npre]
      if(i==j){
        cmps[i, j] <- cmp[x, y] * schportion
      }else if(x == y){
        cmps[i, j] <- cmp[x, y] * (1 - schportion) * schoolpops[j - npre] / (sum(schoolpops[schoolagegroups==x]) - schoolpops[i - npre])
      }else{
        cmps[i, j] <- cmp[x, y] * schoolpops[j - npre] / agepops[y]
      }
    }
  }
  cmps
}
