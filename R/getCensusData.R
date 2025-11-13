#' Get Census Population Data by Age and County
#'
#' Downloads and processes U.S. Census Bureau population estimates for a specified
#' state and county, organized by age groups. Supports single-year age data with
#' optional sex disaggregation.
#'
#' @param state_fips Two-digit FIPS code for the state (e.g., "49" for Utah)
#' @param county_name Name of the county (e.g., "Salt Lake County")
#' @param year Census estimate year: 2020-2024 for July 1 estimates, or 2020.1 for April 1, 2020 base
#' @param age_groups Vector of age limits for grouping (e.g., c(0, 5, 18, 65)).
#'   Default NULL returns single-year ages 0-85+
#' @param by_sex Logical, if TRUE returns separate male/female groups
#' @return A list containing:
#'   \item{county}{County name}
#'   \item{state}{State name}
#'   \item{year}{Census year}
#'   \item{total_pop}{Total population}
#'   \item{age_pops}{Vector of populations by age group}
#'   \item{age_labels}{Labels for each age group}
#'   \item{sex_labels}{If by_sex=TRUE, labels indicating sex}
#'   \item{data}{Full filtered data frame}
#' @examples
#' \dontrun{
#' # Get single-year age data for Salt Lake County
#' slc_data <- getCensusData(state_fips = "49", 
#'                           county_name = "Salt Lake County",
#'                           year = 2024)
#'
#' # Get age groups without sex disaggregation
#' slc_grouped <- getCensusData(state_fips = "49",
#'                              county_name = "Salt Lake County", 
#'                              year = 2024,
#'                              age_groups = c(0, 5, 18, 65))
#'
#' # Get age groups by sex
#' slc_by_sex <- getCensusData(state_fips = "49",
#'                             county_name = "Salt Lake County",
#'                             year = 2024, 
#'                             age_groups = c(0, 5, 18, 65),
#'                             by_sex = TRUE)
#' }
#' @export
getCensusData <- function(state_fips, 
                          county_name, 
                          year = 2024,
                          age_groups = NULL,
                          by_sex = FALSE) {
  # Validate inputs
  if (!year %in% c(2020, 2020.1, 2021, 2022, 2023, 2024)) {
    stop("Year must be 2020, 2020.1 (April 1 base), 2021, 2022, 2023, or 2024")
  }

  # Construct Census URL
  base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
  file_name <- sprintf("cc-est2024-syasex-%s.csv", state_fips)
  census_url <- paste0(base_url, file_name)

  # Download and read data
  message(sprintf("Downloading census data from: %s", census_url))

  tryCatch({
    raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
  }, error = function(e) {
    stop(sprintf("Failed to download census data. Check state FIPS code '%s'.\nError: %s",
                 state_fips, e$message))
  })

  # Clean column names (remove whitespace)
  names(raw_data) <- trimws(names(raw_data))

  # Verify expected columns exist
  required_cols <- c("SUMLEV", "CTYNAME", "YEAR", "AGE", "TOT_POP", "TOT_MALE", "TOT_FEMALE")
  missing_cols <- setdiff(required_cols, names(raw_data))
  if (length(missing_cols) > 0) {
    stop(sprintf("Census file missing expected columns: %s", paste(missing_cols, collapse = ", ")))
  }

  # filter raw data for specific county-level data
  county_data <- raw_data[raw_data$SUMLEV == "50" & grepl(county_name, raw_data$CTYNAME, ignore.case = TRUE), ]

  if (nrow(county_data) == 0) {
    available_counties <- unique(county_level_data$CTYNAME)
    stop(sprintf("County '%s' not found. Available counties:\n%s",
                 county_name,
                 paste(head(available_counties, 20), collapse = "\n")))
  }

  # Convert year input to YEAR code
  year_code <- if (year == 2020.1) 1 else if (year == 2020) 2 else year - 2018

  # Filter for the specified year
  county_data <- county_data[county_data$YEAR == year_code, ]

  if (nrow(county_data) == 0) {
    stop(sprintf("No data found for year %s (YEAR code %d)", year, year_code))
  }

  # Get unique county and state names
  county_full_name <- unique(county_data$CTYNAME)[1]
  state_name <- unique(county_data$STNAME)[1]

  # Process data based on sex disaggregation
  if (by_sex) {
    result <- processCensusDataBySex(county_data, age_groups)
  } else {
    result <- processCensusDataTotal(county_data, age_groups)
  }

  # Add metadata
  result$county <- county_full_name
  result$state <- state_name
  result$year <- year
  result$state_fips <- state_fips
  result$total_pop <- sum(county_data$TOT_POP)

  return(result)
}

#' Process census data without sex disaggregation
#' @keywords internal
processCensusDataTotal <- function(county_data, age_groups) {

  # Sort by age to ensure correct ordering
  county_data <- county_data[order(county_data$AGE), ]

  ages <- county_data$AGE
  pops <- county_data$TOT_POP

  # If age_groups specified, aggregate
  if (!is.null(age_groups)) {
    grouped <- aggregateByAgeGroups(ages, pops, age_groups)
    return(list(
      age_pops = grouped$pops,
      age_labels = grouped$labels,
      ages = grouped$age_ranges,
      data = county_data
    ))
  } else {
    # Return single-year ages
    age_labels <- ifelse(ages < 85, paste0("age", ages), "age85plus")
    return(list(
      age_pops = pops,
      ages = ages,
      age_labels = age_labels,
      data = county_data
    ))
  }
}

#' Process census data with sex disaggregation
#' @keywords internal
processCensusDataBySex <- function(county_data, age_groups) {

  # Sort by age to ensure correct ordering
  county_data <- county_data[order(county_data$AGE), ]

  ages <- county_data$AGE
  male_pops <- county_data$TOT_MALE
  female_pops <- county_data$TOT_FEMALE

  # If age_groups specified, aggregate for each sex
  if (!is.null(age_groups)) {
    male_grouped <- aggregateByAgeGroups(ages, male_pops, age_groups)
    female_grouped <- aggregateByAgeGroups(ages, female_pops, age_groups)

    # Interleave male and female groups: M0-4, F0-4, M5-17, F5-17, etc.
    n_groups <- length(male_grouped$pops)
    combined_pops <- numeric(n_groups * 2)
    combined_labels <- character(n_groups * 2)
    sex_labels <- character(n_groups * 2)

    for (i in 1:n_groups) {
      combined_pops[2*i - 1] <- male_grouped$pops[i]
      combined_pops[2*i] <- female_grouped$pops[i]
      combined_labels[2*i - 1] <- paste0("M_", male_grouped$labels[i])
      combined_labels[2*i] <- paste0("F_", female_grouped$labels[i])
      sex_labels[2*i - 1] <- "Male"
      sex_labels[2*i] <- "Female"
    }

    return(list(
      age_pops = combined_pops,
      age_labels = combined_labels,
      sex_labels = sex_labels,
      data = county_data
    ))
  } else {
    # Return single-year ages for each sex
    n_ages <- length(ages)
    combined_pops <- numeric(n_ages * 2)
    combined_labels <- character(n_ages * 2)
    sex_labels <- character(n_ages * 2)

    for (i in 1:n_ages) {
      age_label <- ifelse(ages[i] < 85, paste0("age", ages[i]), "age85plus")
      combined_pops[2*i - 1] <- male_pops[i]
      combined_pops[2*i] <- female_pops[i]
      combined_labels[2*i - 1] <- paste0("M_", age_label)
      combined_labels[2*i] <- paste0("F_", age_label)
      sex_labels[2*i - 1] <- "Male"
      sex_labels[2*i] <- "Female"
    }

    return(list(
      age_pops = combined_pops,
      ages = rep(ages, each = 2),
      age_labels = combined_labels,
      sex_labels = sex_labels,
      data = county_data
    ))
  }
}

#' Aggregate population by age groups
#' @keywords internal
aggregateByAgeGroups <- function(ages, pops, age_groups) {
  n_groups <- length(age_groups)
  grouped_pops <- numeric(n_groups)
  labels <- character(n_groups)
  age_ranges <- list()

  # Handle single age group case
  if (n_groups == 1) {
    # Single group: all ages >= age_groups[1]
    idx <- ages >= age_groups[1]
    grouped_pops[1] <- sum(pops[idx])
    labels[1] <- sprintf("%dplus", age_groups[1])
    age_ranges[[1]] <- c(age_groups[1], Inf)

    cat(sprintf("Aggregating ages %d and above: sum = %d\n", age_groups[1], grouped_pops[1]))

    return(list(pops = grouped_pops, labels = labels, age_ranges = age_ranges))
  }

  for (i in 1:(n_groups - 1)) {
    lower <- age_groups[i]
    upper <- age_groups[i + 1] - 1

    idx <- ages >= lower & ages <= upper
    grouped_pops[i] <- sum(pops[idx])

    cat(sprintf("Aggregating ages %d to %d: sum = %d\n", lower, upper, grouped_pops[i]))

    if (lower == 0 && upper == 0) {
      labels[i] <- "under1"
    } else if (lower == upper) {
      labels[i] <- sprintf("age%d", lower)
    } else {
      labels[i] <- sprintf("%dto%d", lower, upper)
    }

    age_ranges[[i]] <- c(lower, upper)
  }

  # Last group (age_groups[n_groups] and above)
  idx <- ages >= age_groups[n_groups]
  grouped_pops[n_groups] <- sum(pops[idx])
  labels[n_groups] <- sprintf("%dplus", age_groups[n_groups])
  age_ranges[[n_groups]] <- c(age_groups[n_groups], Inf)

  list(pops = grouped_pops, labels = labels, age_ranges = age_ranges)
}

#' List available counties for a state
#'
#' @param state_fips Two-digit FIPS code for the state
#' @param year Census year (2020-2024), default 2024
#' @return Character vector of county names
#' @examples
#' \dontrun{
#' utah_counties <- listCounties(state_fips = "49", year = 2024)
#' }
#' @export
listCounties <- function(state_fips, year = 2024) {
  base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
  file_name <- sprintf("cc-est2024-syasex-%s.csv", state_fips)
  census_url <- paste0(base_url, file_name)

  message(sprintf("Downloading census data from: %s", census_url))

  tryCatch({
    raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
    counties <- unique(raw_data$CTYNAME)
    return(sort(counties))
  }, error = function(e) {
    stop(sprintf("Failed to download census data for state FIPS '%s'.\nError: %s",
                 state_fips, e$message))
  })
}

#' Get state FIPS code by state name
#'
#' @param state_name State name (e.g., "Utah")
#' @return Two-digit FIPS code as character
#' @examples
#' getStateFIPS("Utah")  # Returns "49"
#' @export
getStateFIPS <- function(state_name) {
  # Standard state FIPS codes
  state_fips_map <- c(
    "Alabama" = "01", "Alaska" = "02", "Arizona" = "04", "Arkansas" = "05",
    "California" = "06", "Colorado" = "08", "Connecticut" = "09", "Delaware" = "10",
    "District of Columbia" = "11", "Florida" = "12", "Georgia" = "13", "Hawaii" = "15",
    "Idaho" = "16", "Illinois" = "17", "Indiana" = "18", "Iowa" = "19",
    "Kansas" = "20", "Kentucky" = "21", "Louisiana" = "22", "Maine" = "23",
    "Maryland" = "24", "Massachusetts" = "25", "Michigan" = "26", "Minnesota" = "27",
    "Mississippi" = "28", "Missouri" = "29", "Montana" = "30", "Nebraska" = "31",
    "Nevada" = "32", "New Hampshire" = "33", "New Jersey" = "34", "New Mexico" = "35",
    "New York" = "36", "North Carolina" = "37", "North Dakota" = "38", "Ohio" = "39",
    "Oklahoma" = "40", "Oregon" = "41", "Pennsylvania" = "42", "Rhode Island" = "44",
    "South Carolina" = "45", "South Dakota" = "46", "Tennessee" = "47", "Texas" = "48",
    "Utah" = "49", "Vermont" = "50", "Virginia" = "51", "Washington" = "53",
    "West Virginia" = "54", "Wisconsin" = "55", "Wyoming" = "56"
  )

  # Try exact match first
  fips <- state_fips_map[state_name]

  # If not found, try case-insensitive partial match
  if (is.na(fips)) {
    matches <- grep(state_name, names(state_fips_map), ignore.case = TRUE, value = TRUE)
    if (length(matches) == 1) {
      fips <- state_fips_map[matches]
    } else if (length(matches) > 1) {
      stop(sprintf("Ambiguous state name '%s'. Matches: %s",
                   state_name, paste(matches, collapse = ", ")))
    } else {
      stop(sprintf("State '%s' not found. Use full state name (e.g., 'Utah')", state_name))
    }
  }

  return(as.character(fips))
}
