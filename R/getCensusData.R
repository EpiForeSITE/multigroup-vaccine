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
#' @param csv_path Optional path to a previously downloaded census CSV file. If provided,
#'   data will be read from this file instead of downloading. Use \code{cache_dir} for
#'   automatic caching.
#' @param cache_dir Optional directory path for caching downloaded census files. If provided,
#'   the function will check for an existing cached file and use it, or download and save
#'   a new one. Default is NULL (no caching). Use "." for current directory or specify
#'   a custom path like "~/census_cache"
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
#' # Use the included example data (recommended for package examples)
#' slc_data <- getCensusData(
#'   state_fips = "49", 
#'   county_name = "Salt Lake County",
#'   year = 2024,
#'   csv_path = getCensusDataPath()
#' )
#'
#' # Get age groups without sex disaggregation
#' slc_grouped <- getCensusData(
#'   state_fips = "49",
#'   county_name = "Salt Lake County", 
#'   year = 2024,
#'   age_groups = c(0, 5, 18, 65),
#'   csv_path = getCensusDataPath()
#' )
#'
#' # Get age groups by sex
#' slc_by_sex <- getCensusData(
#'   state_fips = "49",
#'   county_name = "Salt Lake County",
#'   year = 2024, 
#'   age_groups = c(0, 5, 18, 65),
#'   by_sex = TRUE,
#'   csv_path = getCensusDataPath()
#' )
#'
#' \dontrun{
#' # Download from web (requires internet)
#' slc_web <- getCensusData(
#'   state_fips = "49",
#'   county_name = "Salt Lake County",
#'   year = 2024
#' )
#'
#' # Use caching to avoid repeated downloads
#' slc_cached <- getCensusData(
#'   state_fips = "49",
#'   county_name = "Salt Lake County",
#'   year = 2024,
#'   cache_dir = "~/census_cache"
#' )
#' }
#' @export
getCensusData <- function(state_fips, 
                          county_name, 
                          year = 2024,
                          age_groups = NULL,
                          by_sex = FALSE,
                          csv_path = NULL,
                          cache_dir = NULL) {
  # Validate inputs
  if (!year %in% c(2020, 2020.1, 2021, 2022, 2023, 2024)) {
    stop("Year must be 2020, 2020.1 (April 1 base), 2021, 2022, 2023, or 2024")
  }

  # Construct file name
  file_name <- sprintf("cc-est2024-syasex-%s.csv", state_fips)
  
  # Determine where to read data from
  if (!is.null(csv_path)) {
    # User provided a specific CSV path
    if (!file.exists(csv_path)) {
      stop(sprintf("CSV file not found: %s", csv_path))
    }
    message(sprintf("Reading census data from: %s", csv_path))
    raw_data <- read.csv(csv_path, stringsAsFactors = FALSE)
    
  } else if (!is.null(cache_dir)) {
    # Check cache directory for existing file
    if (!dir.exists(cache_dir)) {
      message(sprintf("Creating cache directory: %s", cache_dir))
      dir.create(cache_dir, recursive = TRUE)
    }
    
    cached_file <- file.path(cache_dir, file_name)
    
    if (file.exists(cached_file)) {
      message(sprintf("Reading cached census data from: %s", cached_file))
      raw_data <- read.csv(cached_file, stringsAsFactors = FALSE)
    } else {
      # Download and cache
      base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
      census_url <- paste0(base_url, file_name)
      
      message(sprintf("Downloading census data from: %s", census_url))
      message(sprintf("Saving to cache: %s", cached_file))
      
      tryCatch({
        raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
        # Save to cache
        write.csv(raw_data, cached_file, row.names = FALSE)
      }, error = function(e) {
        stop(sprintf("Failed to download census data. Check state FIPS code '%s'.\nError: %s",
                     state_fips, e$message))
      })
    }
    
  } else {
    # Download without caching (original behavior)
    base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
    census_url <- paste0(base_url, file_name)
    
    message(sprintf("Downloading census data from: %s", census_url))
    
    tryCatch({
      raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
    }, error = function(e) {
      stop(sprintf("Failed to download census data. Check state FIPS code '%s'.\nError: %s",
                   state_fips, e$message))
    })
  }

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

#' Aggregate population counts into age groups
#'
#' Aggregate per-age population counts into coarser age groups defined by the
#' (sorted) lower bounds in `age_groups`. When `length(age_groups) == 1`, all
#' ages >= that value are aggregated into a single open-ended group ("Xplus").
#' When `length(age_groups) > 1`, groups are formed as
#' [age_groups[i], age_groups[i+1] - 1] for i = 1:(n-1) and
#' [age_groups[n], Inf) for the final group. Human-readable labels are produced:
#' "under1" for the 0–0 group, "ageX" for single-year groups, "XtoY" for ranges,
#' and "Xplus" for the final open group. The function prints aggregation
#' summaries to the console for each group using `cat()`.
#'
#' @param ages Numeric vector of ages (typically integers) corresponding to the
#'   entries in `pops`.
#' @param pops Numeric vector of population counts for each age; must be the
#'   same length as `ages`. Note: NA values in `pops` will propagate into group
#'   sums because `na.rm = TRUE` is not used; clean or impute missing values
#'   beforehand if required.
#' @param age_groups Numeric vector of lower bounds for desired age groups.
#'   Must be sorted in ascending order. If length is 1, the single value defines
#'   an "Xplus" group (ages >= X). For length > 1, contiguous non-overlapping
#'   groups are created as described above.
#' @return A named list with components:
#'   \describe{
#'     \item{pops}{Numeric vector of aggregated population counts, one element per group.}
#'     \item{labels}{Character vector of labels for each group (e.g. "under1", "age5", "0to4", "65plus").}
#'     \item{age_ranges}{List of numeric vectors of length 2 giving the inclusive lower and upper bounds for each group; the upper bound for the final group is `Inf`.}
#'   }
#' @details
#' - Group boundaries are inclusive at both ends for finite ranges (i.e. ages
#'   satisfying lower <= age <= upper). For the last group the upper bound is
#'   infinite.
#' - If no ages fall into a group the aggregated count for that group is 0
#'   (because `sum(numeric(0)) == 0`).
#' - The function writes progress messages to the console with `cat()` for each
#'   aggregated group (useful for debugging / logging).
#' @examples
#' \donttest{
#' # Multiple groups example
#' ages <- 0:100
#' pops <- rep(100, length(ages))
#' aggregateByAgeGroups(ages, pops, c(0, 5, 18, 65))
#'
#' # Single open-ended group (65plus)
#' aggregateByAgeGroups(ages, pops, 65)
#' }
#' @export
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

    cat(sprintf("Aggregating ages %d and above: sum = %g\n", age_groups[1], grouped_pops[1]))

    return(list(pops = grouped_pops, labels = labels, age_ranges = age_ranges))
  }

  for (i in 1:(n_groups - 1)) {
    lower <- age_groups[i]
    upper <- age_groups[i + 1] - 1

    idx <- ages >= lower & ages <= upper
    grouped_pops[i] <- sum(pops[idx])

    cat(sprintf("Aggregating ages %d to %d: sum = %g\n", lower, upper, grouped_pops[i]))

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
#' @param csv_path Optional path to a previously downloaded census CSV file
#' @param cache_dir Optional directory path for caching downloaded census files
#' @return Character vector of county names
#' @examples
#' # Use the included example data
#' utah_counties <- listCounties(
#'   state_fips = "49", 
#'   year = 2024,
#'   csv_path = getCensusDataPath()
#' )
#'
#' \dontrun{
#' # Download from web (requires internet)
#' utah_counties_web <- listCounties(state_fips = "49", year = 2024)
#' 
#' # With caching
#' utah_counties_cached <- listCounties(state_fips = "49", cache_dir = "~/census_cache")
#' }
#' @export
listCounties <- function(state_fips, year = 2024, csv_path = NULL, cache_dir = NULL) {
  file_name <- sprintf("cc-est2024-syasex-%s.csv", state_fips)

  # Determine where to read data from
  if (!is.null(csv_path)) {
    # User provided a specific CSV path
    if (!file.exists(csv_path)) {
      stop(sprintf("CSV file not found: %s", csv_path))
    }
    message(sprintf("Reading census data from: %s", csv_path))
    raw_data <- read.csv(csv_path, stringsAsFactors = FALSE)

  } else if (!is.null(cache_dir)) {
    # Check cache directory for existing file
    if (!dir.exists(cache_dir)) {
      message(sprintf("Creating cache directory: %s", cache_dir))
      dir.create(cache_dir, recursive = TRUE)
    }

    cached_file <- file.path(cache_dir, file_name)

    if (file.exists(cached_file)) {
      message(sprintf("Reading cached census data from: %s", cached_file))
      raw_data <- read.csv(cached_file, stringsAsFactors = FALSE)
    } else {
      # Download and cache
      base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
      census_url <- paste0(base_url, file_name)

      message(sprintf("Downloading census data from: %s", census_url))
      message(sprintf("Saving to cache: %s", cached_file))

      tryCatch({
        raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
        # Save to cache
        write.csv(raw_data, cached_file, row.names = FALSE)
      }, error = function(e) {
        stop(sprintf("Failed to download census data for state FIPS '%s'.\nError: %s",
                     state_fips, e$message))
      })
    }

  } else {
    # Download without caching (original behavior)
    base_url <- "https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/counties/asrh/"
    census_url <- paste0(base_url, file_name)

    message(sprintf("Downloading census data from: %s", census_url))

    tryCatch({
      raw_data <- read.csv(census_url, stringsAsFactors = FALSE)
    }, error = function(e) {
      stop(sprintf("Failed to download census data for state FIPS '%s'.\nError: %s",
                   state_fips, e$message))
    })
  }

  counties <- unique(raw_data$CTYNAME)
  return(sort(counties))
}

#' Get path to example census data file
#'
#' Returns the path to the example Utah census data CSV file included with the package.
#' This is useful for examples, testing, and when internet access is not available.
#'
#' @return Character string with the path to the example census CSV file for Utah (FIPS 49)
#' @examples
#' # Get path to example Utah census file
#' utah_csv <- getCensusDataPath()
#' 
#' # Use it with getCensusData
#' \dontrun{
#' slc_data <- getCensusData(
#'   state_fips = "49",
#'   county_name = "Salt Lake County",
#'   year = 2024,
#'   csv_path = getCensusDataPath()
#' )
#' }
#' @export
getCensusDataPath <- function() {
  system.file("extdata", "cc-est2024-syasex-49.csv", package = "multigroup.vaccine")
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

#' Get City Population Data by Age
#'
#' Reads and processes population data for specific cities from ACS 5-year estimates,
#' organized by age groups. The ACS data provides 5-year age groupings (0-4, 5-9, etc.)
#' which can be disaggregated into single-year ages or aggregated into custom age groups.
#'
#' @param city_name Name of the city (e.g., "Hildale city, Utah")
#' @param csv_path Path to the city population CSV file
#' @param age_groups Vector of age limits for grouping. If NULL, returns single-year ages
#'   (disaggregated from 5-year ACS groups). Default uses 5-year intervals: c(0,5,10,...,85)
#' @return A list containing:
#'   \item{city}{City name}
#'   \item{year}{Data year}
#'   \item{total_pop}{Total population}
#'   \item{age_pops}{Vector of populations by age group}
#'   \item{age_labels}{Labels for each age group}
#'   \item{data}{Full data frame}
#' @examples
#' # Load Hildale data with default 5-year age groups
#' hildale_data <- getCityData(
#'   city_name = "Hildale city, Utah",
#'   csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
#' )
#'
#' # Load with single-year ages (disaggregated)
#' hildale_single <- getCityData(
#'   city_name = "Hildale city, Utah",
#'   csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"),
#'   age_groups = NULL
#' )
#'
#' # Load with custom age groups
#' hildale_custom <- getCityData(
#'   city_name = "Hildale city, Utah",
#'   csv_path = system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"),
#'   age_groups = c(0, 18, 65)
#' )
#' @export
getCityData <- function(city_name, csv_path, age_groups = c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85)) {
  if (!file.exists(csv_path)) {
    stop(sprintf("CSV file not found: %s", csv_path))
  }

  raw_data <- read.csv(csv_path, stringsAsFactors = FALSE)

  # Find the row for the specified city
  city_row <- raw_data[raw_data$NAME == city_name, ]
  if (nrow(city_row) == 0) {
    available_cities <- raw_data$NAME
    stop(sprintf("City '%s' not found. Available cities:\n%s",
                 city_name,
                 paste(available_cities, collapse = "\n")))
  }

  # Extract age group populations from ACS 5-year estimates
  # ACS columns: S0101_C01_001E = total, 002E = under 5, 003E = 5-9, etc.
  age_cols <- c(
    "S0101_C01_002E",  # Under 5 (0-4)
    "S0101_C01_003E",  # 5-9
    "S0101_C01_004E",  # 10-14
    "S0101_C01_005E",  # 15-19
    "S0101_C01_006E",  # 20-24
    "S0101_C01_007E",  # 25-29
    "S0101_C01_008E",  # 30-34
    "S0101_C01_009E",  # 35-39
    "S0101_C01_010E",  # 40-44
    "S0101_C01_011E",  # 45-49
    "S0101_C01_012E",  # 50-54
    "S0101_C01_013E",  # 55-59
    "S0101_C01_014E",  # 60-64
    "S0101_C01_015E",  # 65-69
    "S0101_C01_016E",  # 70-74
    "S0101_C01_017E",  # 75-79
    "S0101_C01_018E",  # 80-84
    "S0101_C01_019E"   # 85+
  )

  acs_age_pops <- as.numeric(city_row[, age_cols])
  total_pop <- as.numeric(city_row$S0101_C01_001E)

  # If age_groups is NULL, disaggregate to single-year ages
  if (is.null(age_groups)) {
    result <- disaggregateCityAges(acs_age_pops)
    return(list(
      city = city_name,
      year = 2023,
      total_pop = total_pop,
      age_pops = result$age_pops,
      age_labels = result$age_labels,
      data = city_row
    ))
  }

  # If age_groups is provided, first disaggregate to single years, then aggregate
  single_year <- disaggregateCityAges(acs_age_pops)
  grouped <- aggregateByAgeGroups(single_year$ages, single_year$age_pops, age_groups)

  return(list(
    city = city_name,
    year = 2023,
    total_pop = total_pop,
    age_pops = grouped$pops,
    age_labels = grouped$labels,
    data = city_row
  ))
}

#' Disaggregate ACS 5-year age groups into single-year ages
#'
#' Takes population counts from ACS 5-year age groupings and uniformly distributes
#' them into single-year ages. This allows for more flexible age group aggregations.
#'
#' @param acs_age_pops Numeric vector of length 18 containing populations for ACS age groups:
#'   0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-44, 45-49, 50-54, 55-59,
#'   60-64, 65-69, 70-74, 75-79, 80-84, 85+
#' @return A list containing:
#'   \item{ages}{Vector of single-year ages (0, 1, 2, ..., 85)}
#'   \item{age_pops}{Vector of populations for each single year}
#'   \item{age_labels}{Vector of labels for each age}
#' @keywords internal
disaggregateCityAges <- function(acs_age_pops) {
  if (length(acs_age_pops) != 18) {
    stop("Expected 18 ACS age groups (0-4, 5-9, ..., 85+)")
  }

  # ACS 5-year age groups (except last which is 85+)
  acs_age_starts <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85)
  acs_age_widths <- c(rep(5, 17), 1)  # 85+ treated as a single year for simplicity

  ages <- numeric()
  age_pops <- numeric()
  age_labels <- character()

  for (i in seq_along(acs_age_pops)) {
    start_age <- acs_age_starts[i]
    width <- acs_age_widths[i]
    total_pop <- acs_age_pops[i]

    # Uniformly distribute population across single years
    pop_per_year <- total_pop / width

    for (j in 0:(width - 1)) {
      age <- start_age + j
      ages <- c(ages, age)
      age_pops <- c(age_pops, pop_per_year)

      if (age < 85) {
        age_labels <- c(age_labels, sprintf("age%d", age))
      } else {
        age_labels <- c(age_labels, "age85plus")
      }
    }
  }

  return(list(
    ages = ages,
    age_pops = age_pops,
    age_labels = age_labels
  ))
}
