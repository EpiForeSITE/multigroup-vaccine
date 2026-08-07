UtahCountyModel <- function(county_school_data){
  # Load census data
  county_pop_data <- getAllCountiesData(
    state_fips = getStateFIPS("Utah"),
    year = 2025,
    csv_path = getCensusDataPath()
  )

  onlinedata <- data.frame(level = 1:3,
                           statepopfrac = c(0.02922, 0.03228, 0.03921),
                           MMR2rate = c(0.58336, 0.72178, 0.77006),
                           priorrate = c(0, 0, 0))

  counties <- unique(county_school_data$county)
  schoolagepoptot <- elemMMR <- middMMR <- highMMR <- rep(0, length(counties))
  for (i in seq_along(counties)) {
    #get age 5-17 census population total for the county
    schoolagepoptot[i] <- sum(county_pop_data[[paste0(counties[i], " County")]]$age_pops[6:18])
    dc <- county_school_data[county_school_data$county == counties[i], ]
    elemMMR[i] <- sum(dc[dc$level == 1, ]$popfrac * dc[dc$level == 1, ]$vaxrate) / sum(dc[dc$level == 1, ]$popfrac)
    middMMR[i] <- sum(dc[dc$level == 2, ]$popfrac * dc[dc$level == 2, ]$vaxrate) / sum(dc[dc$level == 2, ]$popfrac)
    highMMR[i] <- sum(dc[dc$level == 3, ]$popfrac * dc[dc$level == 3, ]$vaxrate) / sum(dc[dc$level == 3, ]$popfrac)
  }

  schoolagepopfrac <- schoolagepoptot / sum(schoolagepoptot)

  getOnlineRates <- function(MMR, delta){
    logitrc <- log(MMR / (1 - MMR))
    logitqc <- logitrc - delta
    qc <- exp(logitqc) / (1 + exp(logitqc))
  }

  elemDelta <- optimize(function(x) (sum(getOnlineRates(elemMMR, x) * schoolagepopfrac) -
                                       onlinedata$MMR2rate[1])^2, c(0, 10))$minimum

  middDelta <- optimize(function(x) (sum(getOnlineRates(middMMR, x) * schoolagepopfrac) -
                                       onlinedata$MMR2rate[2])^2, c(0, 10))$minimum

  highDelta <- optimize(function(x) (sum(getOnlineRates(highMMR, x) * schoolagepopfrac) -
                                       onlinedata$MMR2rate[3])^2, c(0, 10))$minimum

  onlineElemMMR2 <- getOnlineRates(elemMMR, elemDelta)
  onlineMiddMMR2 <- getOnlineRates(middMMR, middDelta)
  onlineHighMMR2 <- getOnlineRates(highMMR, highDelta)
  online_school_data <- data.frame(counties, onlineElemMMR2, onlineMiddMMR2, onlineHighMMR2)

  # School-level age groups by county

  grade_groups_by_county <- list()

  # Grade - level combinations to test
  elem_mid <- cbind(c(4, 4, 5, 5, 6, 6, 7, 7),
                    c(5, 6, 4, 5, 3, 4, 2, 3))

  for (county in unique(county_school_data$county)) {

    #get age 5-17 census population data for the county
    schoolagepop <- county_pop_data[[paste0(counties[i], " County")]]$age_pops[6:18]

    sapfrac <- schoolagepop / sum(schoolagepop)

    dc <- county_school_data[county_school_data$county == county, ]

    # Get population for each level
    elem_popfrac <- sum(dc$popfrac[dc$level == 1])
    mid_popfrac <- sum(dc$popfrac[dc$level == 2])
    high_popfrac <- sum(dc$popfrac[dc$level == 3])

    err <- rep(0, nrow(elem_mid))
    for(i in 1:nrow(elem_mid)){
      ielem <- 1:elem_mid[i,1]
      imid <- (elem_mid[i,1] + 1):rowSums(elem_mid)[i]
      ihigh <- (rowSums(elem_mid)[i] + 1):13
      err[i] <- (sum(schoolagepop[ielem])*(elem_popfrac - sum(sapfrac[ielem])))^2 +
        (sum(schoolagepop[imid])*(mid_popfrac - sum(sapfrac[imid])))^2 +
        (sum(schoolagepop[ihigh])*(high_popfrac - sum(sapfrac[ihigh])))^2
    }
    bestrow <- which.min(err)
    grade_groups_by_county[[county]] <- c(0, elem_mid[bestrow, 1],
                                          rowSums(elem_mid)[bestrow])
  }

  age_groups_pre <- c(0, 1)
  age_groups_adult <- seq(18, 70, 4)

  min_age_adult <- min(age_groups_adult)
  age_range_adult <- diff(range(age_groups_adult))
  adult_midpoints <-
    (age_groups_adult[-length(age_groups_adult)] + age_groups_adult[-1]) / 2

  interpolate_vac <- function(start_vac, end_vac) {
    slope <- (end_vac - start_vac) / age_range_adult
    return(start_vac + slope * (adult_midpoints - min_age_adult))
  }

  county_school_df <- data.frame(county = character(), school_level = numeric(), school_mode = character(), min_age = numeric(), population = numeric(), MMR2 = numeric(), MMR1 = numeric(), priorinf = numeric())

  for (county_name in unique(county_school_data$county)) {
    county_name_long <- paste0(county_name, " County")
    pop_data <- county_pop_data[[county_name_long]]$age_pops
    inperson_school_data <- county_school_data[county_school_data$county == county_name, ]

    min_age <- c(age_groups_pre,
                 5 + grade_groups_by_county[[county_name]][inperson_school_data$level],
                 5 + grade_groups_by_county[[county_name]][1:3],
                 age_groups_adult)

    school_level = c(rep(-1, length(age_groups_pre)),
                     inperson_school_data$level,
                     1:3,
                     rep(-1, length(age_groups_adult)))

    school_mode = c(rep("non-school", length(age_groups_pre)),
                    rep("in-person", nrow(inperson_school_data)),
                    rep("online", 3),
                    rep("non-school", length(age_groups_adult)))

    school_id = c(rep("non-school", length(age_groups_pre)),
                  inperson_school_data$id,
                  rep("online", 3),
                  rep("non-school", length(age_groups_adult)))

    pop_data_agg <- aggregateByAgeGroups(ages = 0:(length(pop_data) - 1),
                                         pops = pop_data,
                                         age_groups = sort(unique(min_age)))$pops

    school_level_pop_total <- pop_data_agg[length(age_groups_pre) + (1:3)]
    school_pop_total <- sum(school_level_pop_total)
    inperson_school_pops <- round(school_pop_total * inperson_school_data$popfrac *
                                    (1 - onlinedata$statepopfrac[inperson_school_data$level]))
    online_school_pops <- round(school_level_pop_total * onlinedata$statepopfrac)

    group_pops <- c(pop_data_agg[1:length(age_groups_pre)],
                    inperson_school_pops, online_school_pops,
                    pop_data_agg[(length(age_groups_pre) + 4):length(pop_data_agg)])

    el_vax_rate <- sum(inperson_school_data$vaxrate[inperson_school_data$level == 1] *
                         inperson_school_data$popfrac[inperson_school_data$level == 1]) /
      sum(inperson_school_data$popfrac[inperson_school_data$level == 1])

    high_vax_rate <- sum(inperson_school_data$vaxrate[inperson_school_data$level == 3] *
                           inperson_school_data$popfrac[inperson_school_data$level == 3]) /
      sum(inperson_school_data$popfrac[inperson_school_data$level == 3])

    pre_k_vax_rate <- el_vax_rate * 0.9
    adult_vax_rates <- interpolate_vac(high_vax_rate, 1)

    online_schools_MMR2 <-
      as.numeric(online_school_data[online_school_data$counties == county_name, 2:4])

    MMR2 <- c(rep(0, length(age_groups_pre)),
              inperson_school_data$vaxrate, online_schools_MMR2, adult_vax_rates, 0)
    MMR1 <- c(0, rep(pre_k_vax_rate, length(age_groups_pre) - 1),
              rep(0, length(MMR2) - length(age_groups_pre)))
    prior <- c(rep(0, length(age_groups_pre)), inperson_school_data$priorrate,
               rep(0, length(age_groups_adult) + 2), 1)

    immune <- MMR2 * 0.97 + MMR1 * 0.93 + prior

    county_school_df <- rbind(county_school_df,
                                data.frame(county = rep(county_name, length(MMR2)),
                                           school_level = school_level,
                                           school_mode = school_mode,
                                           school_id = school_id,
                                           min_age = min_age, population = group_pops,
                                           MMR2 = MMR2, MMR1 = MMR1, priorinf = prior,
                                           immune = immune))
  }

  county_contact_matrices <- list()
  for (county_name in unique(county_school_data$county)) {

    df <- county_school_df[county_school_df$county == county_name, ]
    dfs <- df[df$school_level > 0, ]

    agepopagg <- aggregate(list(pop = df$population), list(min_age = df$min_age), sum)
    agelims <- agepopagg$min_age
    agepops <- agepopagg$pop
    schoolagegroups <- length(age_groups_pre) + dfs$school_level
    schoolpops <- dfs$population
    schportion <- ifelse(dfs$school_mode == "in-person", 0.7, 0)
    schoolids <- dfs$school_id

    county_matrix <- contactMatrixAgeSchool(agelims = agelims,
                                              agepops = agepops,
                                              schoolagegroups = schoolagegroups,
                                              schoolpops = schoolpops,
                                              schportion = schportion,
                                              schoolids = schoolids)

    county_contact_matrices[[county_name]] <- county_matrix
  }

  county_R0_factors <- data.frame(county = character(), R0_factor = numeric())

  nationalCensusDataPath <- system.file("extdata", "nc-est2025-agesex-res.csv", package = "multigroup.vaccine")

  nationalCensusData <- read.csv(nationalCensusDataPath)
  ncdRows <- which(nationalCensusData$SEX == 0 & nationalCensusData$AGE < 200)
  ages <- nationalCensusData$AGE[ncdRows]
  pops <- nationalCensusData$POPESTIMATE2025[ncdRows]

  grade_groups <- unique(grade_groups_by_county)

  reference_eigenvalues <- rep(0, length(grade_groups))
  for(i in seq_along(grade_groups)){
    age_groups <- c(age_groups_pre, 5 + grade_groups[[i]], age_groups_adult)
    age_pops <- aggregateByAgeGroups(ages, pops, age_groups)$pops
    reference_matrix <- contactMatrixPolymod(age_groups, age_pops)
    reference_eigenvalues[i] <- eigen(reference_matrix)$values[1]
  }

  for (county_name in names(county_contact_matrices)) {
    county_matrix <- county_contact_matrices[[county_name]]
    grade_group <- grade_groups_by_county[[county_name]]
    reference_eigenvalue <-
      reference_eigenvalues[[which(sapply(grade_groups, identical, grade_group))]]
    R0_factor <- Re(eigen(county_matrix)$values[1]) / Re(reference_eigenvalue)
    county_R0_factors <- rbind(county_R0_factors, data.frame(
      county = county_name, R0_factor = R0_factor
    ))
  }
  list(county_names = names(county_contact_matrices),
       county_school_df = county_school_df,
       county_contact_matrices = county_contact_matrices,
       county_R0_factors = county_R0_factors)
}

simulateCountyOutbreaks <- function(model, R0, county_name, initmode = c("random", "eachgroup"), nsims){
  df <- model$county_school_df[model$county_school_df$county == county_name, ]
  cm <- model$county_contact_matrices[[county_name]]
  popsize <- df$population
  initV <- round(popsize * df$immune)
  if(initmode == "random"){
    init_group <- sample(length(popsize), nsims, replace = TRUE, prob = (popsize - initV) * rowSums(cm))
    initI <- matrix(0, nsims, length(popsize))
    initI[cbind(1:nsims, init_group)] <- 1
  }else if(initmode == "eachgroup"){
    init_group <- rep(which(popsize - initV > 0), each = nsims)
    initI <- matrix(0, length(init_group), length(popsize))
    initI[cbind(1:length(init_group), init_group)] <- 1
  }else{
    stop("initmode not recognized")
  }
  R0_eff <- R0 * model$county_R0_factors$R0_factor[model$county_R0_factors$county == county_name]
  initR <- rep(0, length(popsize))
  transmmatrix <- transmissionRates(R0_eff, 1, cm)
  fsd <- getFinalSizeDist(length(init_group), transmmatrix, 1, popsize, initR, initI, initV)
  list(final_size = fsd, init_group = init_group, group_names = colnames(cm))
}
