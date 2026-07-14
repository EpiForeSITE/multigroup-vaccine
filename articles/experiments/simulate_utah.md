# Measles Outbreak Simulator for Utah

WARNING: The data and model used in this vignette are for demonstration
purposes only and do not reflect real-world conditions accurately. The
results are not intended to forecast or predict a measles outbreak size
in any specific location.

Executive Summary

This vignette provides code for setting up and running stochastic
measles outbreak simulations for every school district in Utah. The
simulation inputs include demographic mixing patterns and explicit
representation of individual schools, with vaccination coverage
assumptions based on measles-mumps-rubella (MMR) vaccination data.

``` r

library(multigroup.vaccine)
library(socialmixr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)
library(scales)
library(stringr)
library(purrr)
```

## Data Initialization

First we read the school data, which contains relative school enrollment
data, the level of each school, vaccination rates for each school, and
rates of prior infection with measles. The file
“school_district_schoolID_data_Utah_2025.csv” must be read from your
local machine.

``` r


# Load raw data
school_data <- read.csv(file.path("../../data-raw/school_district_schoolID_data_Utah_2025.csv"))
```

## Set up model elements used in simulation

``` r

model <- multigroup.vaccine:::UtahSchoolDistrictModel(school_data)
```

The `model` object now contains a list of modeling elements that are
used in the `simulateOutbreaks` function below and that don’t need to be
accessed directly for purposes of this vignette, with the exception of
`model$district_names` that contains the names of all the school
districts

``` r

model$district_names
#>  [1] "Beaver"         "Box Elder"      "Cache"          "Logan"         
#>  [5] "Carbon"         "Daggett"        "Davis"          "Duchesne"      
#>  [9] "Uintah"         "Emery"          "Garfield"       "Grand"         
#> [13] "Iron"           "Juab"           "Tintic"         "Kane"          
#> [17] "Millard"        "Morgan"         "Piute"          "Rich"          
#> [21] "Canyons"        "Granite"        "Salt Lake City" "Jordan"        
#> [25] "Murray"         "San Juan"       "North Sanpete"  "South Sanpete" 
#> [29] "Sevier"         "Park City"      "North Summit"   "South Summit"  
#> [33] "Tooele"         "Provo"          "Alpine"         "Nebo"          
#> [37] "Wasatch"        "Washington"     "Wayne"          "Ogden"         
#> [41] "Weber"
```

## Simulate a school district

``` r


#Run 20 simulations each starting with 1 initial infection in a random group 
randomsim <- multigroup.vaccine:::simulateOutbreaks(model,
                                                    R0 = 7,
                                                    district_name = "Piute",
                                                    initmode = "random",
                                                    nsims = 20)

#Run 10 simulations for EACH group, i.e. each group has the initial infection 10 times
groupsim <- multigroup.vaccine:::simulateOutbreaks(model,
                                                   R0 = 7,
                                                   district_name = "Piute",
                                                   initmode = "eachgroup",
                                                   nsims = 10)
```

The output contains a list of the following:

The matrix `final_size`, which has a row for each simulation and a
column for each group, and the values are the total number of
infections, including the initial infection, for each group in each
simulation at the end of the outbreak.

``` r

randomsim$final_size
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13]
#>  [1,]    0    0    0    0    0    0    0    0    0     0     0     0     2
#>  [2,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [3,]    0    1    0    0    1    1    1    0    4     0     0     0     0
#>  [4,]    0    3    0    0    5    0    1    0    9     1     0     0     2
#>  [5,]    0    1    0    0    0    0    0    0    0     0     0     0     1
#>  [6,]    0    1    0    0    0    0    0    0    0     0     0     0     0
#>  [7,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>  [8,]    0    0    0    0    0    0    0    0    1     0     0     0     0
#>  [9,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#> [10,]    1    0    0    0    0    0    0    0    0     0     0     0     0
#> [11,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#> [12,]    0    0    0    0    5    0    0    0    1     0     0     0     0
#> [13,]    0    0    0    0    0    0    0    0    0     0     0     0     1
#> [14,]    0    1    0    0    4    2    0    0    0     0     0     0     0
#> [15,]    0    1    0    0    0    0    0    0    0     0     0     0     0
#> [16,]    0    0    0    0    3    0    0    0    1     1     0     0     1
#> [17,]    0    1    0    0    0    0    0    0    0     0     0     0     0
#> [18,]    0    0    0    0    0    0    0    0    0     0     0     0     1
#> [19,]    0    0    0    0    0    1    0    0    0     0     0     0     0
#> [20,]    0    0    0    0    0    0    0    0    0     0     0     0     0
#>       [,14] [,15] [,16] [,17] [,18] [,19] [,20] [,21] [,22] [,23] [,24] [,25]
#>  [1,]     0     0     0     0     0     0     0     0     0     0     0     0
#>  [2,]     1     0     0     0     0     0     1     0     0     0     0     0
#>  [3,]     0     0     0     1     2     0     1     0     0     0     0     0
#>  [4,]     1     1     0     3     3     1     2     0     0     0     0     0
#>  [5,]     0     0     0     0     0     0     0     0     0     0     0     0
#>  [6,]     0     0     0     0     0     0     0     0     0     0     0     0
#>  [7,]     1     0     0     1     0     0     0     0     0     0     0     0
#>  [8,]     0     0     0     0     0     0     0     0     0     0     0     0
#>  [9,]     0     0     0     1     0     0     0     0     0     0     0     0
#> [10,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [11,]     0     0     0     1     0     0     0     1     0     0     0     0
#> [12,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [13,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [14,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [15,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [16,]     1     0     0     0     0     0     0     0     0     0     0     0
#> [17,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [18,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [19,]     0     0     0     0     0     0     0     0     0     0     0     0
#> [20,]     0     0     0     0     0     0     0     0     0     0     0     1
#>       [,26]
#>  [1,]     0
#>  [2,]     0
#>  [3,]     0
#>  [4,]     0
#>  [5,]     0
#>  [6,]     0
#>  [7,]     0
#>  [8,]     0
#>  [9,]     0
#> [10,]     0
#> [11,]     0
#> [12,]     0
#> [13,]     0
#> [14,]     0
#> [15,]     0
#> [16,]     0
#> [17,]     0
#> [18,]     0
#> [19,]     0
#> [20,]     0
```

The vector `init_group`, which specifies the group index (column of
`final_size`) for the group in which the initial infection of the
outbreak occurred.

``` r

randomsim$init_group
#>  [1] 13 20  7  5 13  2 14  9 17  1 21  5 13  6  2  5  2 13  6 25
```

The vector `group_names`, which has the name of each group in the same
order as the columns of `final_size`. The group name specifies the age
group and the ID of the school or “online” if applicable.

``` r

randomsim$group_names
#>  [1] "under1"        "1to4"          "15to17_S1323"  "12to14_S1323" 
#>  [5] "5to11_S1323"   "15to17_S0796"  "12to14_S0796"  "5to11_S0761"  
#>  [9] "5to11_S0192"   "5to11_online"  "12to14_online" "15to17_online"
#> [13] "18to21"        "22to25"        "26to29"        "30to33"       
#> [17] "34to37"        "38to41"        "42to45"        "46to49"       
#> [21] "50to53"        "54to57"        "58to61"        "62to65"       
#> [25] "66to69"        "70+"
```

## Stochastic Simulation for every school district

We run 1000 independent simulations per school district, each with a
random initial infection in a non-immune individual within the
population, for each assumed value of the reference R0.

``` r

nsims_stochastic <- 1000

R0_baseline <- 8
R0_baseline_range <- seq(6, 10, by=1)

sim_list <- vector("list", length(R0_baseline_range) * length(model$district_names))
idx <- 1L

for (district_name in model$district_names) {
  for (R0_stochastic in R0_baseline_range) {
    
    # Run pure stochastic simulation
    sim <- multigroup.vaccine:::simulateOutbreaks(model, R0_stochastic, district_name, "random", nsims_stochastic)
    fs_stochastic <- sim$final_size
    init_group <- sim$init_group
    
    total_infected <- rowSums(fs_stochastic)
    
    # Store all sims
    sim_list[[idx]] <- data.frame(
      baseline_R0 = R0_stochastic,
      district = district_name,
      total_cases = total_infected
    )
    idx <- idx + 1L
  }
}

sim_long <- bind_rows(sim_list)
```

## Full Outbreak Distribution

All 1000 simulations per school district are shown. A bimodal
distribution — a spike closer to zero (chains that fizzle out) and a
heavier right tail (sustained outbreaks) — is a hallmark of stochastic
outbreak size distribution for populations above the herd immunity
threshold.

``` r

if (nrow(sim_long) > 0) {

  # Order by mean outbreak size at R0_baseline
  order_all <- sim_long %>%
    filter(baseline_R0 == R0_baseline) %>%
    group_by(district) %>%
    summarise(avg = mean(total_cases), .groups = "drop") %>%
    arrange(avg) %>%
    pull(district)

  all_sim_districts <- unique(sim_long$district)
  order_all_full <- c(order_all, sort(setdiff(all_sim_districts, order_all)))

  p_dots <- plot_ly()

  for (r0_val in R0_baseline_range) {

    df_sub <- sim_long %>%
      filter(baseline_R0 == r0_val) %>%
      count(district, total_cases, name = "n_equal") %>%
      arrange(district, total_cases) %>%
      group_by(district) %>%
      mutate(
        n_greater = rev(cumsum(rev(n_equal))) - n_equal,
        district_f = factor(district, levels = order_all_full)
      ) %>%
      ungroup()

    p_dots <- p_dots %>%
      add_trace(
        data = df_sub,
        x = ~total_cases,
        y = ~district_f,
        type = "scattergl",
        mode = "markers",
        marker = list(color = "#000000", size = 4),
        hovertext = ~paste0(
          district,
          "<br>= ", scales::comma(total_cases), " ",
          ifelse(total_cases == 1, "case", "cases"),
          ": ", n_equal, " ",
          ifelse(n_equal == 1, "simulation", "simulations"),
          "<br>> ", scales::comma(total_cases), " ",
          ifelse(total_cases == 1, "case", "cases"),
          ": ", n_greater, " ",
          ifelse(n_greater == 1, "simulation", "simulations")
        ),
        hoverinfo = "text",
        visible = (r0_val == R0_baseline),
        name = paste0("R0 = ", r0_val)
      )
  }

  steps_dots <- lapply(seq_along(R0_baseline_range), function(i) {
    vis <- rep(FALSE, length(R0_baseline_range))
    vis[i] <- TRUE
    list(
      method = "restyle",
      args = list("visible", as.list(vis)),
      label = as.character(R0_baseline_range[i])
    )
  })

  max_cases <- max(sim_long$total_cases[sim_long$total_cases > 0], na.rm = TRUE)
  min_cases <- min(sim_long$total_cases[sim_long$total_cases > 0], na.rm = TRUE)

  p_dots %>% layout(
    title = paste0(
      "Full Distribution of Outbreak Final Size: ",
      scales::comma(nsims_stochastic),
      " Simulations"
    ),
    xaxis = list(
      title = "Total Cases per Simulation (log scale)",
      type = "log",
      range = c(-0.1, log10(max_cases) + 0.1)
    ),
    yaxis = list(title = "", tickfont = list(size = 8)),
    sliders = list(list(
      active = 2,
      currentvalue = list(prefix = "Baseline R0 = "),
      steps = steps_dots
    )),
    showlegend = FALSE,
    margin = list(l = 100)
  )

} else {
  print("No simulation results.")
}
```
