#Source: https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/cc-est2024-agesex-49.csv

raw <- read.csv('data-raw/cc-est2024-agesex-49.csv')

recentyear <- max(raw$YEAR)
rawr <- raw[raw$YEAR == recentyear, ]

age0to4 <- rawr$AGE04_TOT
age5to9 <- rawr$AGE59_TOT
age10to13 <- rawr$AGE513_TOT - rawr$AGE59_TOT
age14 <- rawr$AGE1014_TOT - age10to13
age15 <- rawr$POPESTIMATE - rawr$AGE16PLUS_TOT - age0to4 - age5to9 - age10to13 - age14
age16to17 <- rawr$AGE16PLUS_TOT - rawr$AGE18PLUS_TOT
age18to19 <- rawr$AGE1519_TOT - age15 - age16to17

UtahAgeCountyPop <- data.frame(
  county = rawr$CTYNAME,
  total = rawr$POPESTIMATE,
  age0to4 = age0to4,
  age5to9 = age5to9,
  age10to13 = age10to13,
  age14 = age14,
  age15 = age15,
  age16to17 = age16to17,
  age18to19 = age18to19,
  age20to24 = rawr$AGE2024_TOT,
  age25to29 = rawr$AGE2529_TOT,
  age30to34 = rawr$AGE3034_TOT,
  age35to39 = rawr$AGE3539_TOT,
  age40to44 = rawr$AGE4044_TOT,
  age45to49 = rawr$AGE4549_TOT,
  age50to54 = rawr$AGE5054_TOT,
  age55to59 = rawr$AGE5559_TOT,
  age60to64 = rawr$AGE6064_TOT,
  age65to69 = rawr$AGE6569_TOT,
  age70to74 = rawr$AGE7074_TOT,
  age75to79 = rawr$AGE7579_TOT,
  age80to84 = rawr$AGE8084_TOT,
  age85plus = rawr$AGE85PLUS_TOT
)

usethis::use_data(UtahAgeCountyPop, overwrite = TRUE)
