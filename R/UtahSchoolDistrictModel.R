UtahSchoolDistrictModel <- function(county_sd_school_data){
  # Load census data
  county_pop_data <- getAllCountiesData(
    state_fips = getStateFIPS("Utah"),
    year = 2025,
    csv_path = getCensusDataPath()
  )
  county_acs_data <- read.csv(system.file("extdata", "acs_Utah_2023_counties.csv", package = "multigroup.vaccine"))
  school_district_acs_data <- read.csv(system.file("extdata", "acs_Utah_2023_school_districts.csv", package = "multigroup.vaccine"))

  # Standardize school district and county names

  county_sd_school_data$schooldistrictlocation <- stringr::str_to_title(county_sd_school_data$schooldistrictlocation)
  county_sd_school_data$schooldistrictlocation[county_sd_school_data$schooldistrictlocation == "Salt Lake"] <- "Salt Lake City"

  #There is a school located in Duchesne County that is part of Uintah School District and seems to enroll students living in Uintah County only - change its county to Uintah so that the analysis comes out right

  county_sd_school_data$county[county_sd_school_data$county == "Duchesne" & county_sd_school_data$schooldistrictlocation == "Uintah"] <- "Uintah"

  names(county_acs_data) <- sub("..Utah..Total..Estimate", "", names(county_acs_data))
  names(school_district_acs_data) <- sub("..UT", "", names(school_district_acs_data))

  county_sd_lookup <- unique(county_sd_school_data[,c("county", "schooldistrictlocation")])
  names(county_sd_lookup) <- c("county_name", "district_name")
  county_sd_lookup$county_name <- paste0(county_sd_lookup$county_name, " County")
  county_sd_lookup$district_name <- paste0(county_sd_lookup$district_name, " School District")

  age_breaks <- sort(unique(as.integer(county_acs_data$Min.Age)))
  band_min_for_age <- function(age) {
    age_breaks[findInterval(age, age_breaks)]
  }

  county_acs_long <- county_acs_data %>%
    mutate(Min.Age = as.integer(Min.Age)) %>%
    pivot_longer(
      cols = -Min.Age,
      names_to = "county_col",
      values_to = "county_acs"
    ) %>%
    mutate(
      county_name = str_replace_all(county_col, "\\.", " "),
      county_acs = as.numeric(county_acs)
    )

  district_acs_long <- school_district_acs_data %>%
    mutate(Min.Age = as.integer(Min.Age)) %>%
    pivot_longer(
      cols = -Min.Age,
      names_to = "district_col",
      values_to = "district_acs"
    ) %>%
    mutate(
      district_name = str_replace_all(district_col, "\\.", " "),
      district_acs = as.numeric(district_acs)
    )

  normal_weights <- district_acs_long %>%
    left_join(county_sd_lookup, by = "district_name") %>%
    filter(
      !is.na(county_name),
      county_name != "Grand County",
      county_name != "San Juan County"
    ) %>%
    left_join(
      county_acs_long %>% select(county_name, Min.Age, county_acs),
      by = c("county_name", "Min.Age")
    ) %>%
    mutate(weight = district_acs / county_acs) %>%
    select(county_name, district_name, Min.Age, weight)

  # ---- special handling for Grand / San Juan ----
  # Assumption:
  #   Grand County residents are all assigned to Grand School District.
  #   Any excess Grand School District population above Grand County is in San Juan County.
  #   San Juan County residents are then split between Grand SD spill and San Juan SD.

  grand_special <- district_acs_long %>%
    filter(district_name == "Grand School District") %>%
    select(Min.Age, grand_district_acs = district_acs) %>%
    left_join(
      county_acs_long %>%
        filter(county_name == "Grand County") %>%
        select(Min.Age, grand_county_acs = county_acs),
      by = "Min.Age"
    ) %>%
    left_join(
      county_acs_long %>%
        filter(county_name == "San Juan County") %>%
        select(Min.Age, san_juan_county_acs = county_acs),
      by = "Min.Age"
    ) %>%
    mutate(
      grand_spill_in_sanjuan = pmax(grand_district_acs - grand_county_acs, 0),
      san_juan_sdia_share = grand_spill_in_sanjuan / san_juan_county_acs,
      san_juan_sd_share = (san_juan_county_acs - grand_spill_in_sanjuan) / san_juan_county_acs
    )

  special_weights <- bind_rows(
    grand_special %>%
      transmute(
        county_name = "Grand County",
        district_name = "Grand School District",
        Min.Age,
        weight = 1
      ),
    grand_special %>%
      transmute(
        county_name = "San Juan County",
        district_name = "Grand School District",
        Min.Age,
        weight = san_juan_sdia_share
      ),
    grand_special %>%
      transmute(
        county_name = "San Juan County",
        district_name = "San Juan School District",
        Min.Age,
        weight = san_juan_sd_share
      )
    )
  # ---- combine and check ----

  all_weights <- bind_rows(normal_weights, special_weights)

  weight_check <- all_weights %>%
    group_by(county_name, Min.Age) %>%
    summarise(sum_weight = sum(weight), .groups = "drop")

  stopifnot(all(abs(weight_check$sum_weight - 1) < 1e-8))

  # ---- county PEP single-age data to long form ----
  # Each county list element should contain age_pops with ages 0..85 (85 = 85+ bucket)

  county_pep_long <- imap_dfr(county_pop_data, function(x, county_name) {
    pops <- as.numeric(x$age_pops)
    ages <- 0:(length(pops) - 1)

    tibble(
      county_name = county_name,
      age = ages,
      pep_pop = pops,
      Min.Age = band_min_for_age(ages)
    )
  })

  # ---- allocate county single-age populations to school districts ----

  district_age_estimates <- county_pep_long %>%
    left_join(all_weights, by = c("county_name", "Min.Age")) %>%
    mutate(district_pop = round(pep_pop * weight)) %>%
    group_by(district_name, age) %>%
    summarise(population = sum(district_pop), .groups = "drop") %>%
    arrange(district_name, age)

  onlinedata <- data.frame(level = 1:3,
                           statepopfrac = c(0.02922, 0.03228, 0.03921),
                           MMR2rate = c(0.58336, 0.72178, 0.77006),
                           priorrate = c(0, 0, 0))

  districts <- unique(county_sd_school_data$schooldistrictlocation)
  schoolagepoptot <- elemMMR <- middMMR <- highMMR <- rep(0, length(districts))
  for (i in seq_along(districts)) {
    #get age 5-17 census population total for the school district
    schoolagepoptot[i] <- sum(district_age_estimates$population[district_age_estimates$district_name ==
                                                                  paste0(districts[i], " School District")][6:18])
    dsd <- county_sd_school_data[county_sd_school_data$schooldistrictlocation == districts[i], ]
    elemMMR[i] <- sum(dsd[dsd$level == 1, ]$popfrac * dsd[dsd$level == 1, ]$vaxrate) / sum(dsd[dsd$level == 1, ]$popfrac)
    middMMR[i] <- sum(dsd[dsd$level == 2, ]$popfrac * dsd[dsd$level == 2, ]$vaxrate) / sum(dsd[dsd$level == 2, ]$popfrac)
    highMMR[i] <- sum(dsd[dsd$level == 3, ]$popfrac * dsd[dsd$level == 3, ]$vaxrate) / sum(dsd[dsd$level == 3, ]$popfrac)
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
  online_school_data <- data.frame(districts, onlineElemMMR2, onlineMiddMMR2, onlineHighMMR2)

  # School-level age groups by school district

  grade_groups_by_district <- list()

  # Grade - level combinations to test
  elem_mid <- cbind(c(4, 4, 5, 5, 6, 6, 7, 7),
                    c(5, 6, 4, 5, 3, 4, 2, 3))

  for (district in unique(county_sd_school_data$schooldistrictlocation)) {

    #get age 5-17 census population data for the school district
    schoolagepop <- district_age_estimates$population[district_age_estimates$district_name ==
                                                        paste0(districts[i], " School District")][6:18]
    sapfrac <- schoolagepop / sum(schoolagepop)

    dsd <- county_sd_school_data[county_sd_school_data$schooldistrictlocation == district, ]

    # Get population for each level
    elem_popfrac <- sum(dsd$popfrac[dsd$level == 1])
    mid_popfrac <- sum(dsd$popfrac[dsd$level == 2])
    high_popfrac <- sum(dsd$popfrac[dsd$level == 3])

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
    grade_groups_by_district[[district]] <- c(0, elem_mid[bestrow, 1],
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

  district_school_df <- data.frame(district = character(), school_level = numeric(), school_mode = character(), min_age = numeric(), population = numeric(), MMR2 = numeric(), MMR1 = numeric(), priorinf = numeric())

  for (district_name in unique(county_sd_school_data$schooldistrictlocation)) {
    district_name_long <- paste0(district_name, " School District")
    pop_data <- district_age_estimates$population[district_age_estimates$district_name == district_name_long]
    inperson_school_data <- county_sd_school_data[county_sd_school_data$schooldistrictlocation == district_name, ]

    min_age <- c(age_groups_pre,
                 5 + grade_groups_by_district[[district_name]][inperson_school_data$level],
                 5 + grade_groups_by_district[[district_name]][1:3],
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
      as.numeric(online_school_data[online_school_data$districts == district_name, 2:4])

    MMR2 <- c(rep(0, length(age_groups_pre)),
              inperson_school_data$vaxrate, online_schools_MMR2, adult_vax_rates, 0)
    MMR1 <- c(0, rep(pre_k_vax_rate, length(age_groups_pre) - 1),
              rep(0, length(MMR2) - length(age_groups_pre)))
    prior <- c(rep(0, length(age_groups_pre)), inperson_school_data$priorrate,
               rep(0, length(age_groups_adult) + 2), 1)

    immune <- MMR2 * 0.97 + MMR1 * 0.93 + prior

    district_school_df <- rbind(district_school_df,
                                data.frame(district = rep(district_name, length(MMR2)),
                                           school_level = school_level,
                                           school_mode = school_mode,
                                           school_id = school_id,
                                           min_age = min_age, population = group_pops,
                                           MMR2 = MMR2, MMR1 = MMR1, priorinf = prior,
                                           immune = immune))
  }

  district_contact_matrices <- list()
  for (district_name in unique(county_sd_school_data$schooldistrictlocation)) {

    df <- district_school_df[district_school_df$district == district_name, ]
    dfs <- df[df$school_level > 0, ]

    agepopagg <- aggregate(list(pop = df$population), list(min_age = df$min_age), sum)
    agelims <- agepopagg$min_age
    agepops <- agepopagg$pop
    schoolagegroups <- length(age_groups_pre) + dfs$school_level
    schoolpops <- dfs$population
    schportion <- ifelse(dfs$school_mode == "in-person", 0.7, 0)
    schoolids <- dfs$school_id

    district_matrix <- contactMatrixAgeSchool(agelims = agelims,
                                              agepops = agepops,
                                              schoolagegroups = schoolagegroups,
                                              schoolpops = schoolpops,
                                              schportion = schportion,
                                              schoolids = schoolids)

    district_contact_matrices[[district_name]] <- district_matrix
  }

  district_R0_factors <- data.frame(district = character(), R0_factor = numeric())

  nationalCensusDataPath <- system.file("extdata", "nc-est2025-agesex-res.csv", package = "multigroup.vaccine")

  nationalCensusData <- read.csv(nationalCensusDataPath)
  ncdRows <- which(nationalCensusData$SEX == 0 & nationalCensusData$AGE < 200)
  ages <- nationalCensusData$AGE[ncdRows]
  pops <- nationalCensusData$POPESTIMATE2025[ncdRows]

  grade_groups <- unique(grade_groups_by_district)

  reference_eigenvalues <- rep(0, length(grade_groups))
  for(i in seq_along(grade_groups)){
    age_groups <- c(age_groups_pre, 5 + grade_groups[[i]], age_groups_adult)
    age_pops <- aggregateByAgeGroups(ages, pops, age_groups)$pops
    reference_matrix <- contactMatrixPolymod(age_groups, age_pops)
    reference_eigenvalues[i] <- eigen(reference_matrix)$values[1]
  }

  for (district_name in names(district_contact_matrices)) {
    district_matrix <- district_contact_matrices[[district_name]]
    grade_group <- grade_groups_by_district[[district_name]]
    reference_eigenvalue <-
      reference_eigenvalues[[which(sapply(grade_groups, identical, grade_group))]]
    R0_factor <- Re(eigen(district_matrix)$values[1]) / Re(reference_eigenvalue)
    district_R0_factors <- rbind(district_R0_factors, data.frame(
      district = district_name, R0_factor = R0_factor
    ))
  }
  list(district_names = names(district_contact_matrices),
       district_school_df = district_school_df,
       district_contact_matrices = district_contact_matrices,
       district_R0_factors = district_R0_factors)
}

simulateOutbreaks <- function(model, R0, district_name, initmode = c("random", "eachgroup"), nsims){
  df <- model$district_school_df[model$district_school_df$district == district_name, ]
  cm <- model$district_contact_matrices[[district_name]]
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
  R0_eff <- R0 * model$district_R0_factors$R0_factor[model$district_R0_factors$district == district_name]
  initR <- rep(0, length(popsize))
  transmmatrix <- transmissionRates(R0_eff, 1, cm)
  fsd <- getFinalSizeDist(length(init_group), transmmatrix, 1, popsize, initR, initI, initV)
  list(final_size = fsd, init_group = init_group, group_names = colnames(cm))
}
