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
hildale_path <- system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
colorado_city_path <- system.file("extdata", "colorado_city_az_2023.csv", package = "multigroup.vaccine")
centennial_park_path <- system.file("extdata", "centennial_park_az_2023.csv", package = "multigroup.vaccine")
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
  schoolpops[inds] <- round(agepops[a] * schoolpops[inds] / sum(schoolpops[inds]))
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
                        immunity = paste0(round(100 * groupimm / grouppops),"%")),
             row.names = FALSE, format = "markdown")
```

| group    | size | immunity |
|:---------|-----:|:---------|
| under1   |  113 | 0%       |
| 1to4     |  450 | 24%      |
| 5to11s1  |  281 | 6%       |
| 5to11s2  |  393 | 32%      |
| 5to11s3  |  213 | 37%      |
| 12to13s4 |   85 | 22%      |
| 12to13s5 |  149 | 36%      |
| 12to13s6 |   83 | 58%      |
| 14to17s7 |  178 | 15%      |
| 14to17s8 |  169 | 23%      |
| 14to17s9 |  320 | 28%      |
| 18to24   |  892 | 23%      |
| 25to44   | 1279 | 58%      |
| 45to69   |  962 | 92%      |
| 70+      |   63 | 100%     |

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
|   7 |    13.4 |  9.8 |
|   8 |    15.3 | 11.2 |
|   9 |    17.2 | 12.7 |
|  10 |    19.2 | 14.1 |
|  11 |    21.1 | 15.5 |
|  12 |    23.0 | 16.9 |

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
|   7 |         3094 |
|   8 |         3108 |
|   9 |         3117 |
|  10 |         3123 |
|  11 |         3127 |
|  12 |         3129 |

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
| 3            |    1 |
| 3114         |    1 |
| 3116         |    1 |
| 3117         |    1 |
| 3118         |    2 |
| 3119         |    2 |
| 3120         |    4 |
| 3121         |    6 |
| 3122         |    7 |
| 3123         |    7 |
| 3124         |   17 |
| 3125         |   13 |
| 3126         |    7 |
| 3127         |    6 |
| 3128         |    8 |
| 3129         |    2 |
| 3130         |    3 |
| 3132         |    2 |

## Final comments

These results show a high likelihood of more than 3,000 measles
infections in this community after an introduction, which comprises all
unvaccinated individuals and a small number of vaccinated individuals
also getting infected. This is consistent with the high transmissibility
of measles and the large number of children and low vaccination rates in
the area. Nonetheless, these results should be taken with caution, as
this simulation is a simplification of reality that does not consider,
for example, individuals’ changing behavior, e.g. dramatically reducing
contact rates or taking other precautionary actions upon observing a
measles outbreak occurring in the community.
