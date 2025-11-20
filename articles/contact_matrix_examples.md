# Contact Matrix Examples

``` r
library(multigroup.vaccine)
library(socialmixr)
```

Set up age groups:

``` r
# under 1, 1-4, 5-11, 12-13, 14-17, 18-24, 25-44, 45-69, 70 plus
agelims <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)
agepops <- c(100, 400, 700, 200, 400, 700, 2000, 2400, 1000)
```

Generate contact matrix using Polymod data:

``` r
cmp <- multigroup.vaccine:::contactMatrixPolymod(agelims, agepops)
round(cmp, 2)
#>          contact.age.group
#> age.group under1 1to4 5to11 12to13 14to17 18to24 25to44 45to69  70+
#>    under1   0.42 0.72  0.57   0.09   0.21   0.32   2.11   1.14 0.13
#>    1to4     0.18 2.98  1.52   0.16   0.24   0.49   3.28   1.89 0.35
#>    5to11    0.08 0.87  8.79   0.82   0.46   0.46   3.35   1.88 0.37
#>    12to13   0.04 0.32  2.86   7.98   2.50   0.57   2.77   2.22 0.47
#>    14to17   0.05 0.24  0.80   1.25   9.67   2.21   2.71   2.51 0.37
#>    18to24   0.05 0.28  0.46   0.16   1.26   5.72   3.68   2.87 0.37
#>    25to44   0.11 0.66  1.17   0.28   0.54   1.29   5.72   3.83 0.61
#>    45to69   0.05 0.32  0.55   0.18   0.42   0.84   3.20   4.27 0.96
#>    70+      0.01 0.14  0.26   0.09   0.15   0.26   1.22   2.30 1.57
```

The sum of each row represents the relative overall contact rate of each
group:

``` r
round(rowSums(cmp), 2)
#> under1   1to4  5to11 12to13 14to17 18to24 25to44 45to69    70+ 
#>   5.72  11.11  17.09  19.74  19.82  14.86  14.20  10.78   6.01
```

Those row sums can be factored out to generate the fraction of each
group’s contacts that are with each group: The sum of each row
represents the relative overall contact rate of each group:

``` r
round(cmp/rowSums(cmp), 2)
#>          contact.age.group
#> age.group under1 1to4 5to11 12to13 14to17 18to24 25to44 45to69  70+
#>    under1   0.07 0.13  0.10   0.02   0.04   0.06   0.37   0.20 0.02
#>    1to4     0.02 0.27  0.14   0.01   0.02   0.04   0.29   0.17 0.03
#>    5to11    0.00 0.05  0.51   0.05   0.03   0.03   0.20   0.11 0.02
#>    12to13   0.00 0.02  0.14   0.40   0.13   0.03   0.14   0.11 0.02
#>    14to17   0.00 0.01  0.04   0.06   0.49   0.11   0.14   0.13 0.02
#>    18to24   0.00 0.02  0.03   0.01   0.08   0.38   0.25   0.19 0.03
#>    25to44   0.01 0.05  0.08   0.02   0.04   0.09   0.40   0.27 0.04
#>    45to69   0.00 0.03  0.05   0.02   0.04   0.08   0.30   0.40 0.09
#>    70+      0.00 0.02  0.04   0.02   0.02   0.04   0.20   0.38 0.26
```

Now we split the age groups for elementary school (5-11), middle school
(12-13), and high school (18-24) into two schools each:

``` r
schoolagegroups <- c(3, 3, 4, 4, 5, 5)
schoolpops <- c(350, 350, 100, 100, 200, 200)
```

We can access the Polymod data to specify the number of contacts that
occurred at school:

``` r
cmAll <- contact_matrix(socialmixr::polymod, age.limits = agelims)$matrix
#> Removing participants without age information. To change this behaviour, set the 'missing.participant.age' option
#> Removing participants that have contacts without age information. To change this behaviour, set the 'missing.contact.age' option
cmSchool <- contact_matrix(socialmixr::polymod, age.limits = agelims, filter = list(cnt_school = 1))$matrix
#> Removing participants without age information. To change this behaviour, set the 'missing.participant.age' option
#> Removing participants that have contacts without age information. To change this behaviour, set the 'missing.contact.age' option

round(cmAll, 2)
#>          contact.age.group
#> age.group [0,1) [1,5) [5,12) [12,14) [14,18) [18,25) [25,45) [45,70)  70+
#>   [0,1)    0.33  0.83   0.75    0.10    0.33    0.55    3.72    1.82 0.16
#>   [1,5)    0.07  2.34   1.38    0.19    0.25    0.51    3.62    1.81 0.32
#>   [5,12)   0.03  0.64   7.43    0.86    0.45    0.44    3.68    1.76 0.30
#>   [12,14)  0.03  0.17   1.99    7.14    2.47    0.63    3.35    2.03 0.35
#>   [14,18)  0.01  0.17   0.65    1.07    9.10    2.11    2.98    2.15 0.21
#>   [18,25)  0.01  0.21   0.41    0.13    1.22    5.64    4.14    2.63 0.29
#>   [25,45)  0.04  0.53   1.03    0.23    0.53    1.29    6.55    3.52 0.44
#>   [45,70)  0.02  0.26   0.50    0.18    0.46    0.91    4.01    4.34 0.74
#>   70+      0.01  0.11   0.25    0.10    0.20    0.31    1.72    2.75 1.48
round(cmSchool, 2)
#>          contact.age.group
#> age.group [0,1) [1,5) [5,12) [12,14) [14,18) [18,25) [25,45) [45,70)  70+
#>   [0,1)    0.14  0.09   0.03    0.00    0.14    0.02    0.31    0.01 0.00
#>   [1,5)    0.01  1.45   0.43    0.02    0.02    0.02    0.47    0.18 0.01
#>   [5,12)   0.00  0.18   5.17    0.40    0.05    0.07    0.72    0.40 0.00
#>   [12,14)  0.00  0.01   0.62    5.57    1.38    0.07    0.86    0.48 0.01
#>   [14,18)  0.01  0.03   0.07    0.46    6.21    0.64    0.76    0.52 0.00
#>   [18,25)  0.00  0.03   0.04    0.01    0.42    2.02    0.36    0.20 0.00
#>   [25,45)  0.00  0.05   0.18    0.02    0.07    0.10    0.27    0.09 0.00
#>   [45,70)  0.00  0.06   0.15    0.04    0.12    0.05    0.11    0.10 0.01
#>   70+      0.00  0.00   0.01    0.00    0.01    0.00    0.00    0.01 0.00
```

Based on this we assume that 70% of a student’s within-age-group
contacts occur at their own school:

``` r
schportion <- 0.70
```

Now we build a new matrix:

``` r
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
```
