# Short Creek model with age and school structure

``` r
library(multigroup.vaccine)
library(socialmixr)

# Load city data files
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
#> Aggregating ages 0 to 0: sum = 11.4
#> Aggregating ages 1 to 4: sum = 45.6
#> Aggregating ages 5 to 11: sum = 182.4
#> Aggregating ages 12 to 13: sum = 72.4
#> Aggregating ages 14 to 17: sum = 130.4
#> Aggregating ages 18 to 24: sum = 196.8
#> Aggregating ages 25 to 44: sum = 352
#> Aggregating ages 45 to 69: sum = 265

colorado_city <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = colorado_city_path,
  age_groups = agelims
)
#> Aggregating ages 0 to 0: sum = 25
#> Aggregating ages 1 to 4: sum = 100
#> Aggregating ages 5 to 11: sum = 387
#> Aggregating ages 12 to 13: sum = 174
#> Aggregating ages 14 to 17: sum = 373.8
#> Aggregating ages 18 to 24: sum = 480.2
#> Aggregating ages 25 to 44: sum = 532
#> Aggregating ages 45 to 69: sum = 508

centennial_park <- getCityData(
  city_name = "Centennial Park CDP, Arizona",
  csv_path = centennial_park_path,
  age_groups = agelims
)
#> Aggregating ages 0 to 0: sum = 76.2
#> Aggregating ages 1 to 4: sum = 304.8
#> Aggregating ages 5 to 11: sum = 318
#> Aggregating ages 12 to 13: sum = 72
#> Aggregating ages 14 to 17: sum = 163.2
#> Aggregating ages 18 to 24: sum = 214.8
#> Aggregating ages 25 to 44: sum = 395
#> Aggregating ages 45 to 69: sum = 189

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
    )$totalSize
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
