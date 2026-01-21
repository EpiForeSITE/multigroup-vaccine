# Measles Age-Structured Model

``` r
library(multigroup.vaccine)
library(socialmixr)
```

``` r
getOutputTable <- function(agelims, agepops, agecovr, ageveff, initgrp) {

  grpnames <- c(
    paste0("under", agelims[2]),
    paste0(agelims[2:(length(agelims) - 1)], "to", agelims[3:length(agelims)] - 1),
    paste0(agelims[length(agelims)], "+")
  )

  agevacimmune <- round(agepops * agecovr * ageveff)

  mijpolymod <- contactMatrixPolymod(agelims)
  mijlocal <- contactMatrixPolymod(agelims, agepops)
  R0factor <- eigen(mijlocal)$values[1] / eigen(mijpolymod)$values[1]

  pops <- agepops
  initV <- agevacimmune

  initI <- rep(0, length(pops))
  initI[initgrp] <- 1
  initR <- rep(0, length(pops))

  R0vals <- 10:18
  meaninf <- 7

  R0local <- rep(0, length(R0vals))
  Rv <- rep(0, length(R0vals))
  escapesize <- matrix(0, length(R0vals), length(pops))

  for (i in seq_along(R0vals)) {
    R0local[i] <- R0vals[i] * R0factor

    betaij <- transmissionRates(
      R0 = R0local[i],
      meaninf = meaninf,
      reltransm = mijlocal
    )

    Rv[i] <- vaxrepnum(meaninf, agepops, betaij, initR, agecovr * agepops, ageveff)

    if (Rv[i] < 1) {
      escapesize[i, ] <- rep(0, length(pops))
    } else {
      escapesize[i, ] <- getFinalSizeODE(
        transmrates = betaij,
        recoveryrate = 1 / meaninf,
        popsize = pops,
        initR = initR,
        initI = initI,
        initV = initV
      )
    }
    escapesizetot <- rowSums(escapesize)
  }

  numsims <- 1000

  probescape <- rep(0, length(R0vals))
  for (i in seq_along(R0vals)) {
    if (Rv[i] < 1) {
      probescape[i] <- 0
    } else {
      betaij <- transmissionRates(
        R0 = R0local[i],
        meaninf = meaninf,
        reltransm = mijlocal
      )
      size_dist <- getFinalSizeDistEscape(
        n = numsims,
        transmrates = betaij,
        recoveryrate = 1 / meaninf,
        popsize = pops,
        initR = initR,
        initV = initV,
        initI = initI
      )
      probescape[i] <- sum(rowSums(size_dist) > escapesizetot[i] * 0.9) / numsims
    }
  }

  tbl <- cbind(R0vals, R0local, Rv, probescape, round(escapesizetot), round(escapesize))
  colnames(tbl) <- c("R0", "R0local", "Rv", "pEscape", "escapeInfTot", grpnames)
  tbl
}
```

``` r
# under 1, 1-4, 5-11, 12-17, 18-24, 25-44, 45-69, 70 plus
agelims <- c(0, 1, 5, 12, 18, 25, 45, 70)
ageveff <- c(0.93, 0.93, rep(0.97, 5), 1)

agepops <- c(2354, 9418, 19835, 17001, 19219, 47701, 53956, 32842)
agecovr <- c(0, 0.83, 0.852, 0.879, 0.9, 0.925, 0.95, 1)
initgrp <- 6 # assume first case in 25-44 group

ot1 <- getOutputTable(
  agelims = agelims,
  agepops = c(2354, 9418, 19835, 17001, 19219, 47701, 53956, 32842),
  agecovr = c(0, 0.83, 0.852, 0.879, 0.9, 0.925, 0.95, 1),
  ageveff = ageveff,
  initgrp = initgrp
)

print(as.data.frame(ot1), row.names = FALSE)
#>  R0  R0local       Rv pEscape escapeInfTot under1 1to4 5to11 12to17 18to24
#>  10 10.69458 1.547278   0.205         9258    536  833  2264   1734   1010
#>  11 11.76404 1.702006   0.261        10985    685 1021  2548   1927   1230
#>  12 12.83349 1.856734   0.322        12444    826 1184  2757   2067   1418
#>  13 13.90295 2.011462   0.365        13678    957 1324  2912   2169   1576
#>  14 14.97241 2.166189   0.397        14726   1078 1442  3028   2245   1708
#>  15 16.04187 2.320917   0.420        15620   1189 1542  3117   2303   1819
#>  16 17.11133 2.475645   0.450        16385   1290 1628  3185   2346   1911
#>  17 18.18078 2.630373   0.491        17042   1382 1700  3238   2380   1989
#>  18 19.25024 2.785101   0.524        17609   1466 1761  3279   2406   2054
#>  25to44 45to69 70+
#>    1822   1060   0
#>    2237   1336   0
#>    2599   1593   0
#>    2913   1828   0
#>    3183   2043   0
#>    3414   2237   0
#>    3612   2413   0
#>    3782   2572   0
#>    3927   2716   0
```

``` r
ot2 <- getOutputTable(
  agelims = agelims,
  agepops = c(11981, 47922, 86718, 77302, 120132, 199914, 136997, 38206),
  agecovr = c(0, 0.86, 0.899, 0.933, 0.95, 0.95, 0.95, 1),
  ageveff = ageveff,
  initgrp = initgrp
)

print(as.data.frame(ot2), row.names = FALSE)
#>  R0  R0local       Rv pEscape escapeInfTot under1 1to4 5to11 12to17 18to24
#>  10 13.52980 1.394501   0.172        27675   2733 3627  6460   4230   3417
#>  11 14.88278 1.533951   0.225        34539   3653 4608  7577   4970   4368
#>  12 16.23576 1.673401   0.266        40271   4503 5428  8388   5509   5170
#>  13 17.58874 1.812851   0.343        45070   5275 6106  8989   5910   5838
#>  14 18.94172 1.952301   0.356        49104   5970 6666  9440   6212   6393
#>  15 20.29470 2.091751   0.398        52511   6592 7128  9784   6443   6855
#>  16 21.64768 2.231201   0.475        55404   7146 7511 10050   6623   7239
#>  17 23.00066 2.370652   0.438        57871   7639 7828 10256   6763   7560
#>  18 24.35364 2.510102   0.477        59987   8078 8093 10419   6873   7830
#>  25to44 45to69 70+
#>    5008   2200   0
#>    6449   2914   0
#>    7699   3574   0
#>    8774   4178   0
#>    9695   4727   0
#>   10483   5225   0
#>   11158   5677   0
#>   11738   6087   0
#>   12236   6460   0
```

``` r
ot3 <- getOutputTable(
  agelims = agelims,
  agepops = c(14527, 58108, 114156, 106006, 118837, 367597, 310945, 95637),
  agecovr = c(0, 0.89, 0.949, 0.950, 0.95, 0.95, 0.95, 1),
  ageveff = ageveff,
  initgrp = initgrp
)

print(as.data.frame(ot3), row.names = FALSE)
#>  R0  R0local        Rv pEscape escapeInfTot under1 1to4 5to11 12to17 18to24
#>  10 11.49021 0.9479753   0.000            0      0    0     0      0      0
#>  11 12.63924 1.0427728   0.063         5979    495  571   782   1006    580
#>  12 13.78826 1.1375704   0.109        18249   1623 1803  2305   2709   1780
#>  13 14.93728 1.2323679   0.183        28990   2726 2918  3532   3919   2832
#>  14 16.08630 1.3271654   0.212        38233   3761 3889  4506   4809   3732
#>  15 17.23532 1.4219629   0.258        46153   4713 4720  5281   5481   4495
#>  16 18.38434 1.5167605   0.316        52946   5580 5427  5902   6000   5141
#>  17 19.53336 1.6115580   0.350        58790   6366 6028  6405   6406   5689
#>  18 20.68239 1.7063555   0.390        63836   7076 6541  6815   6730   6155
#>  25to44 45to69 70+
#>       0      0   0
#>    1648    897   0
#>    5152   2877   0
#>    8305   4757   0
#>   11049   6486   0
#>   13407   8057   0
#>   15422   9474   0
#>   17145  10750   0
#>   18620  11900   0
```
