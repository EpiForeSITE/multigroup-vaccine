# Short Creek model with age and school structure

This is an experimental model to estimate the size of a measles outbreak
in the community informally known as Short Creek that spans the Utah /
Arizona border. We incorporate some real vaccination data from publicly
available sources, and population age structure and composition from US
census data. Vaccination rates for some schools and for the
non-school-aged population were imputed based on assumptions and are not
based on actual vaccination information for those age groups.

``` r

library(multigroup.vaccine)
library(socialmixr)
```

## Load city data files

The following census-designated cities / places are assumed to comprise
the Short Creek community:

``` r

hildale_path <- system.file("extdata", "hildale_ut_2024.csv", package = "multigroup.vaccine")
colorado_city_path <- system.file("extdata", "colorado_city_az_2024.csv", package = "multigroup.vaccine")
centennial_park_path <- system.file("extdata", "centennial_park_az_2024.csv", package = "multigroup.vaccine")
```

## Measles Model Setup

For measles outbreak modeling, let’s use the following age groups:

``` r

agelims <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)
ageveff <- c(0.93, 0.93, rep(0.97, 6), 1)
```

## Getting City Population Data

``` r

hildale <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = hildale_path,
  age_groups = agelims
)

colorado_city <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = colorado_city_path,
  age_groups = agelims
)

centennial_park <- getCityData(
  city_name = "Centennial Park CDP, Arizona",
  csv_path = centennial_park_path,
  age_groups = agelims
)

agepops <- round(hildale$age_pops + colorado_city$age_pops + centennial_park$age_pops)
```

## School data

``` r

schoolpops <- c(250, 350, 190, 86, 150, 84, 114, 108, 205)
schoolagegroups <- c(3, 3, 3, 4, 4, 4, 5, 5, 5)
schoolvax <- c(16, 129, 80, 20, 55, 50, 27, 40, 93)

knitr::kable(data.frame(school = c(paste0("elem",1:3),
                                   paste0("middle",1:3),
                                   paste0("high",1:3)),
                        enrolled = schoolpops,
                        MMRcoverage = paste0(round(100 * schoolvax / schoolpops),"%")),
             row.names = FALSE, format = "markdown")
```

| school  | enrolled | MMRcoverage |
|:--------|---------:|:------------|
| elem1   |      250 | 6%          |
| elem2   |      350 | 37%         |
| elem3   |      190 | 42%         |
| middle1 |       86 | 23%         |
| middle2 |      150 | 37%         |
| middle3 |       84 | 60%         |
| high1   |      114 | 24%         |
| high2   |      108 | 37%         |
| high3   |      205 | 45%         |

## Create contact matrix and immunization vector

``` r

#Readjust the school populations to match the age data:
for(a in unique(schoolagegroups)){
  inds <- which(schoolagegroups == a)
  schoolpopsnew <- round(agepops[a] * schoolpops[inds] / sum(schoolpops[inds]))
  schoolvax[inds] <- round(schoolpopsnew * schoolvax[inds] / schoolpops[inds])
  schoolpops[inds] <- schoolpopsnew
}
cm <- contactMatrixAgeSchool(agelims, agepops, schoolagegroups, schoolpops, schportion = 0.7)
grouppops <- c(agepops[1:(min(schoolagegroups)-1)],
               schoolpops,
               agepops[(max(schoolagegroups)+1):length(agepops)])
groupvax <- rep(0, nrow(cm))

groupvax[1] <- 0 #Under 1 unvaccinated
groupvax[2] <- grouppops[2] * sum(schoolvax[schoolagegroups == 3]) / sum(schoolpops[schoolagegroups == 3])
groupvax[3:11] <- schoolvax
groupvax[12] <- grouppops[12] * sum(schoolvax[schoolagegroups == 5]) / sum(schoolpops[schoolagegroups == 5])
groupvax[13] <- grouppops[13] * mean(c(groupvax[12] / grouppops[12], 0.95))
groupvax[14] <- grouppops[14] * 0.95
groupvax[15] <- grouppops[15]

groupveff <- rep(0.97, length(groupvax))
groupveff[1:2] <- 0.93
groupveff[length(groupveff)] <- 1
groupimm <- round(groupvax * groupveff)

knitr::kable(data.frame(group = rownames(cm),
                        size = grouppops,
                        vax = round(groupvax),
                        vaxpc = paste0(round(100 * groupvax / grouppops), "%"),
                        immune = groupimm,
                        immunepc= paste0(round(100 * groupimm / grouppops), "%")),
             row.names = FALSE, format = "markdown")
```

| group    | size | vax | vaxpc | immune | immunepc |
|:---------|-----:|----:|:------|-------:|:---------|
| under1   |  141 |   0 | 0%    |      0 | 0%       |
| 1to4     |  562 | 160 | 29%   |    149 | 27%      |
| 5to11s1  |  296 |  19 | 6%    |     18 | 6%       |
| 5to11s2  |  414 | 153 | 37%   |    148 | 36%      |
| 5to11s3  |  225 |  95 | 42%   |     92 | 41%      |
| 12to13s4 |   94 |  22 | 23%   |     21 | 22%      |
| 12to13s5 |  164 |  60 | 37%   |     58 | 35%      |
| 12to13s6 |   92 |  55 | 60%   |     53 | 58%      |
| 14to17s7 |  166 |  39 | 23%   |     38 | 23%      |
| 14to17s8 |  158 |  59 | 37%   |     57 | 36%      |
| 14to17s9 |  299 | 136 | 45%   |    132 | 44%      |
| 18to24   |  817 | 307 | 38%   |    298 | 36%      |
| 25to44   | 1391 | 922 | 66%   |    894 | 64%      |
| 45to69   | 1016 | 965 | 95%   |    936 | 92%      |
| 70+      |   80 |  80 | 100%  |     80 | 100%     |

## Set up outbreak analysis

``` r

mijpolymod <- contactMatrixPolymod(agelims)
R0factor <- eigen(cm)$values[1] / eigen(mijpolymod)$values[1]

initI <- rep(0, length(grouppops))
initI[12] <- 1
initR <- rep(0, length(grouppops))

R0vals <- 7:12
meaninf <- 7

R0local <- R0vals * R0factor
Rv <- rep(0, length(R0vals))
for (i in seq_along(R0vals)){
  betaij <- transmissionRates(R0local[i], meaninf, cm)
  Rv[i] <- multigroup.vaccine:::vaxrepnum(meaninf, grouppops, betaij, initR, groupimm, 1)
}
knitr::kable(data.frame(R0 = R0vals,
                        R0local = round(R0local, 1),
                        Rvax = round(Rv, 1)),
             row.names = FALSE, format = "markdown")
```

|  R0 | R0local | Rvax |
|----:|--------:|-----:|
|   7 |    12.7 |  8.3 |
|   8 |    14.5 |  9.5 |
|   9 |    16.3 | 10.6 |
|  10 |    18.1 | 11.8 |
|  11 |    19.9 | 13.0 |
|  12 |    21.7 | 14.2 |

## Run deterministic outbreaks

``` r

escapesize <- matrix(0, length(R0vals), length(grouppops))
for (i in seq_along(R0vals)) {

  betaij <- transmissionRates(
    R0 = R0local[i],
    meaninf = meaninf,
    reltransm = cm
  )
  
  if (Rv[i] < 1) {
    escapesize[i, ] <- rep(0, length(pops))
  } else {
    escapesize[i, ] <- getFinalSizeODE(
      transmrates = betaij,
      recoveryrate = 1 / meaninf,
      popsize = grouppops,
      initR = initR,
      initI = initI,
      initV = groupimm
    )
  }
  escapesizetot <- rowSums(escapesize)
}
knitr::kable(data.frame(R0 = R0vals, outbreakSize = round(escapesizetot)),
             row.names = FALSE, format = "markdown")
```

|  R0 | outbreakSize |
|----:|-------------:|
|   7 |         2882 |
|   8 |         2902 |
|   9 |         2915 |
|  10 |         2923 |
|  11 |         2928 |
|  12 |         2932 |

## Run full stochastic simulations

``` r

R0 <- 10
R0local <- R0 * R0factor

betaij <- transmissionRates(
  R0 = R0local,
  meaninf = meaninf,
  reltransm = cm
)
  
fsd <- getFinalSizeDist(
  n = 100,
  transmrates = betaij,
  recoveryrate = 1 / meaninf,
  popsize = grouppops,
  initR = initR,
  initI = initI,
  initV = groupimm
)

os <- data.frame(table(rowSums(fsd)))
colnames(os) <- c("outbreakSize", "freq")
knitr::kable(os, row.names = FALSE, format = "markdown")
```

| outbreakSize | freq |
|:-------------|-----:|
| 1            |   10 |
| 2            |    1 |
| 3            |    1 |
| 2911         |    1 |
| 2912         |    1 |
| 2913         |    1 |
| 2916         |    2 |
| 2917         |    3 |
| 2918         |    1 |
| 2919         |    6 |
| 2920         |    2 |
| 2921         |    7 |
| 2922         |    2 |
| 2923         |   11 |
| 2924         |    8 |
| 2925         |    5 |
| 2926         |    8 |
| 2927         |    9 |
| 2928         |    2 |
| 2929         |    7 |
| 2930         |    5 |
| 2931         |    3 |
| 2932         |    3 |
| 2933         |    1 |

## Final comments

These results show a high likelihood of nearly 3,000 measles infections
in this community after an introduction, which comprises all
unvaccinated individuals and a small number of vaccinated individuals
also getting infected. This is consistent with the high transmissibility
of measles and the large number of children and low vaccination rates in
the area. Nonetheless, these results should be taken with caution, as
this simulation is a simplification of reality that does not consider,
for example, individuals’ changing behavior, e.g. dramatically reducing
contact rates or taking other precautionary actions upon observing a
measles outbreak occurring in the community.
