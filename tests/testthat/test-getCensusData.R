test_that("getCensusDataPath returns valid path", {
  path <- getCensusDataPath()
  
  expect_type(path, "character")
  expect_true(file.exists(path))
  expect_match(path, "cc-est2024-syasex-49\\.csv$")
})

test_that("getStateFIPS returns correct FIPS codes", {
  expect_equal(getStateFIPS("Utah"), "49")
  expect_equal(getStateFIPS("California"), "06")
  expect_equal(getStateFIPS("New York"), "36")
  expect_equal(getStateFIPS("Florida"), "12")
  expect_equal(getStateFIPS("Texas"), "48")
})

test_that("getStateFIPS handles case-insensitive input", {
  expect_equal(getStateFIPS("utah"), "49")
  expect_equal(getStateFIPS("UTAH"), "49")
  expect_equal(getStateFIPS("UtAh"), "49")
})

test_that("getStateFIPS throws error for invalid state", {
  expect_error(getStateFIPS("InvalidState"), "not found")
})

test_that("listCounties returns county names from local file", {
  csv_path <- getCensusDataPath()
  counties <- listCounties(state_fips = "49", csv_path = csv_path)
  
  expect_type(counties, "character")
  expect_true(length(counties) > 0)
  expect_true("Salt Lake County" %in% counties)
  expect_true("Utah County" %in% counties)
  expect_true(is.character(counties))
  expect_true(all(!is.na(counties)))
})

test_that("getCensusData retrieves basic county data", {
  csv_path <- getCensusDataPath()
  
  data <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    csv_path = csv_path
  )
  
  expect_type(data, "list")
  expect_true("county" %in% names(data))
  expect_true("state" %in% names(data))
  expect_true("year" %in% names(data))
  expect_true("total_pop" %in% names(data))
  expect_true("age_pops" %in% names(data))
  expect_true("age_labels" %in% names(data))
  
  expect_equal(data$state, "Utah")
  expect_match(data$county, "Salt Lake County")
  expect_equal(data$year, 2024)
  expect_true(data$total_pop > 0)
})

test_that("getCensusData returns correct single-year age structure", {
  csv_path <- getCensusDataPath()
  
  data <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    csv_path = csv_path
  )
  
  # Should have 86 age groups (0 through 85+)
  expect_equal(length(data$age_pops), 86)
  expect_equal(length(data$age_labels), 86)
  expect_equal(length(data$ages), 86)
  
  # Check labels are correct format
  expect_match(data$age_labels[1], "^age0$")
  expect_match(data$age_labels[50], "^age49$")
  expect_match(data$age_labels[86], "age85plus")
  
  # Sum of age populations should equal total
  expect_equal(sum(data$age_pops), data$total_pop)
})

test_that("getCensusData aggregates by age groups correctly", {
  csv_path <- getCensusDataPath()
  
  age_groups <- c(0, 5, 18, 65)
  data <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    age_groups = age_groups,
    csv_path = csv_path
  )
  
  # Should have 4 age groups
  expect_equal(length(data$age_pops), 4)
  expect_equal(length(data$age_labels), 4)
  
  # Check labels
  expect_equal(data$age_labels[1], "0to4")
  expect_equal(data$age_labels[2], "5to17")
  expect_equal(data$age_labels[3], "18to64")
  expect_equal(data$age_labels[4], "65plus")
  
  # Sum should still equal total
  expect_equal(sum(data$age_pops), data$total_pop)
})

test_that("getCensusData handles single age group", {
  csv_path <- getCensusDataPath()
  
  data <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    age_groups = c(65),
    csv_path = csv_path
  )
  
  expect_equal(length(data$age_pops), 1)
  expect_equal(data$age_labels[1], "65plus")
  expect_true(data$age_pops[1] > 0)
})

test_that("getCensusData handles sex disaggregation", {
  csv_path <- getCensusDataPath()
  
  age_groups <- c(0, 18, 65)
  data <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    age_groups = age_groups,
    by_sex = TRUE,
    csv_path = csv_path
  )
  
  # Should have 6 groups (3 age groups × 2 sexes)
  expect_equal(length(data$age_pops), 6)
  expect_equal(length(data$age_labels), 6)
  expect_equal(length(data$sex_labels), 6)
  
  # Check interleaving pattern
  expect_match(data$age_labels[1], "^M_")
  expect_match(data$age_labels[2], "^F_")
  expect_equal(data$sex_labels[1], "Male")
  expect_equal(data$sex_labels[2], "Female")
  
  # Sum should equal total
  expect_equal(sum(data$age_pops), data$total_pop)
})

test_that("getCensusData handles different years", {
  csv_path <- getCensusDataPath()
  
  data_2020 <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2020,
    csv_path = csv_path
  )
  
  data_2024 <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    csv_path = csv_path
  )
  
  expect_equal(data_2020$year, 2020)
  expect_equal(data_2024$year, 2024)
  
  # Populations should be different (generally increasing)
  expect_true(data_2020$total_pop != data_2024$total_pop)
})

test_that("getCensusData throws error for missing county", {
  csv_path <- getCensusDataPath()
  
  expect_error(
    getCensusData(
      state_fips = "49",
      county_name = "Nonexistent County",
      year = 2024,
      csv_path = csv_path
    ),
    "not found"
  )
})

test_that("getCensusData throws error for invalid year", {
  csv_path <- getCensusDataPath()
  
  expect_error(
    getCensusData(
      state_fips = "49",
      county_name = "Salt Lake County",
      year = 2015,
      csv_path = csv_path
    ),
    "Year must be"
  )
})

test_that("getCensusData throws error for missing file", {
  expect_error(
    getCensusData(
      state_fips = "49",
      county_name = "Salt Lake County",
      year = 2024,
      csv_path = "/nonexistent/path/file.csv"
    ),
    "CSV file not found"
  )
})

test_that("aggregateByAgeGroups handles standard grouping", {
  ages <- 0:100
  pops <- rep(100, 101)
  age_groups <- c(0, 5, 18, 65)
  
  result <- aggregateByAgeGroups(ages, pops, age_groups)
  
  expect_equal(length(result$pops), 4)
  expect_equal(length(result$labels), 4)
  expect_equal(length(result$age_ranges), 4)
  
  # Check populations
  expect_equal(result$pops[1], 500)   # ages 0-4 (5 years)
  expect_equal(result$pops[2], 1300)  # ages 5-17 (13 years)
  expect_equal(result$pops[3], 4700)  # ages 18-64 (47 years)
  expect_equal(result$pops[4], 3600)  # ages 65+ (36 years)
  
  # Sum should equal input
  expect_equal(sum(result$pops), sum(pops))
})

test_that("aggregateByAgeGroups handles edge cases", {
  ages <- 0:100
  pops <- rep(100, 101)
  
  # Single year group
  result <- aggregateByAgeGroups(ages, pops, c(0, 1))
  expect_equal(result$labels[1], "under1")
  expect_equal(result$pops[1], 100)
  
  # Same age start and end (single year)
  age_groups <- c(0, 1, 2, 3)
  result <- aggregateByAgeGroups(ages, pops, age_groups)
  expect_match(result$labels[1], "under1")
  expect_match(result$labels[2], "age1")
  expect_match(result$labels[3], "age2")
})

test_that("aggregateByAgeGroups handles single open-ended group", {
  ages <- 0:100
  pops <- rep(100, 101)
  
  result <- aggregateByAgeGroups(ages, pops, c(65))
  
  expect_equal(length(result$pops), 1)
  expect_equal(result$labels[1], "65plus")
  expect_equal(result$pops[1], 3600)  # ages 65-100 (36 years)
  expect_equal(result$age_ranges[[1]][2], Inf)
})

test_that("getCityData loads Hildale data correctly", {
  hildale_path <- system.file("extdata", "hildale_ut_2023.csv", 
                              package = "multigroup.vaccine")
  
  data <- getCityData(
    city_name = "Hildale city, Utah",
    csv_path = hildale_path
  )
  
  expect_type(data, "list")
  expect_equal(data$city, "Hildale city, Utah")
  expect_equal(data$year, 2023)
  expect_true(data$total_pop > 0)
  expect_true(length(data$age_pops) > 0)
  expect_equal(length(data$age_pops), length(data$age_labels))
})

test_that("getCityData loads Colorado City data correctly", {
  cc_path <- system.file("extdata", "colorado_city_az_2023.csv", 
                         package = "multigroup.vaccine")
  
  data <- getCityData(
    city_name = "Colorado City town, Arizona",
    csv_path = cc_path
  )
  
  expect_type(data, "list")
  expect_equal(data$city, "Colorado City town, Arizona")
  expect_equal(data$year, 2023)
  expect_true(data$total_pop > 0)
})

test_that("getCityData handles custom age groups", {
  hildale_path <- system.file("extdata", "hildale_ut_2023.csv", 
                              package = "multigroup.vaccine")
  
  age_groups <- c(0, 18, 65)
  data <- getCityData(
    city_name = "Hildale city, Utah",
    csv_path = hildale_path,
    age_groups = age_groups
  )
  
  expect_equal(length(data$age_pops), 3)
  expect_equal(length(data$age_labels), 3)
  expect_equal(data$age_labels[1], "0to17")
  expect_equal(data$age_labels[2], "18to64")
  expect_equal(data$age_labels[3], "65plus")
})

test_that("getCityData handles NULL age_groups (disaggregation)", {
  hildale_path <- system.file("extdata", "hildale_ut_2023.csv", 
                              package = "multigroup.vaccine")
  
  data <- getCityData(
    city_name = "Hildale city, Utah",
    csv_path = hildale_path,
    age_groups = NULL
  )
  
  # Should disaggregate into single-year ages (0-85)
  expect_equal(length(data$age_pops), 86)
  expect_match(data$age_labels[1], "^age0$")
  expect_match(data$age_labels[86], "age85plus")
})

test_that("getCityData throws error for missing city", {
  hildale_path <- system.file("extdata", "hildale_ut_2023.csv", 
                              package = "multigroup.vaccine")
  
  expect_error(
    getCityData(
      city_name = "Nonexistent City",
      csv_path = hildale_path
    ),
    "not found"
  )
})

test_that("getCityData throws error for missing file", {
  expect_error(
    getCityData(
      city_name = "Hildale city, Utah",
      csv_path = "/nonexistent/path.csv"
    ),
    "CSV file not found"
  )
})

test_that("disaggregateCityAges distributes populations uniformly", {
  # Test with known input
  acs_pops <- rep(500, 18)  # 500 people in each 5-year group
  
  result <- multigroup.vaccine:::disaggregateCityAges(acs_pops)
  
  expect_equal(length(result$ages), 86)
  expect_equal(length(result$age_pops), 86)
  
  # First 5 ages should each have 100 (500/5)
  expect_equal(result$age_pops[1:5], rep(100, 5))
  
  # Last age (85+) should have full 500 (not divided)
  expect_equal(result$age_pops[86], 500)
})

test_that("disaggregateCityAges throws error for wrong input length", {
  expect_error(
    multigroup.vaccine:::disaggregateCityAges(rep(100, 10)),
    "Expected 18 ACS age groups"
  )
})

test_that("processCensusDataTotal returns correct structure", {
  csv_path <- getCensusDataPath()
  raw_data <- read.csv(csv_path, stringsAsFactors = FALSE)
  
  county_data <- raw_data[raw_data$SUMLEV == "50" & 
                          grepl("Salt Lake County", raw_data$CTYNAME), ]
  county_data <- county_data[county_data$YEAR == 6, ]  # 2024
  
  result <- multigroup.vaccine:::processCensusDataTotal(county_data, NULL)
  
  expect_true("age_pops" %in% names(result))
  expect_true("ages" %in% names(result))
  expect_true("age_labels" %in% names(result))
  expect_equal(length(result$age_pops), 86)
})

test_that("processCensusDataBySex returns correct structure", {
  csv_path <- getCensusDataPath()
  raw_data <- read.csv(csv_path, stringsAsFactors = FALSE)
  
  county_data <- raw_data[raw_data$SUMLEV == "50" & 
                          grepl("Salt Lake County", raw_data$CTYNAME), ]
  county_data <- county_data[county_data$YEAR == 6, ]  # 2024
  
  age_groups <- c(0, 18, 65)
  result <- multigroup.vaccine:::processCensusDataBySex(county_data, age_groups)
  
  expect_true("age_pops" %in% names(result))
  expect_true("sex_labels" %in% names(result))
  expect_equal(length(result$age_pops), 6)  # 3 age groups × 2 sexes
  expect_equal(length(result$sex_labels), 6)
  
  # Check alternating pattern
  expect_equal(result$sex_labels[c(1, 3, 5)], rep("Male", 3))
  expect_equal(result$sex_labels[c(2, 4, 6)], rep("Female", 3))
})

test_that("Multiple counties can be processed", {
  csv_path <- getCensusDataPath()
  
  counties <- c("Salt Lake County", "Utah County", "Davis County")
  
  for (county in counties) {
    data <- getCensusData(
      state_fips = "49",
      county_name = county,
      year = 2024,
      csv_path = csv_path
    )
    
    expect_true(data$total_pop > 0)
    expect_match(data$county, county)
  }
})

test_that("Age group aggregation is consistent across methods", {
  csv_path <- getCensusDataPath()
  
  # Get single-year data
  single_year <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    csv_path = csv_path
  )
  
  # Get grouped data
  age_groups <- c(0, 18, 65)
  grouped <- getCensusData(
    state_fips = "49",
    county_name = "Salt Lake County",
    year = 2024,
    age_groups = age_groups,
    csv_path = csv_path
  )
  
  # Manually aggregate single-year to verify
  under18 <- sum(single_year$age_pops[single_year$ages < 18])
  age18to64 <- sum(single_year$age_pops[single_year$ages >= 18 & 
                                         single_year$ages < 65])
  age65plus <- sum(single_year$age_pops[single_year$ages >= 65])
  
  expect_equal(grouped$age_pops[1], under18)
  expect_equal(grouped$age_pops[2], age18to64)
  expect_equal(grouped$age_pops[3], age65plus)
})
