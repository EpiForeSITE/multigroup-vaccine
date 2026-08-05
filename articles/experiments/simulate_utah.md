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
rates of prior infection with measles.

Not the file “school_district_schoolID_data_Utah_2025.csv” contains
randomized vaccination data and is not accurate. Those with access to
the real data should replace this file.

``` r


# Load raw data
#school_data <- read.csv(file.path("../../data-raw/school_district_schoolID_data_Utah_2025real.csv"))
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

## Function for simulating each school district in a given health district

``` r

sch <- read.csv(system.file("extdata", "Utah_school_county_health_districts.csv", package = "multigroup.vaccine"))

health_district_sims <- function(health_district_name, model, R0, nsims){
  stopifnot(health_district_name %in% sch$Health.District)
  school_districts <- sch$School.District[sch$Health.District == health_district_name]
  
  hd_sims <- vector("list", length(school_districts))
  names(hd_sims) <- school_districts
  
  for(sd in school_districts){
    hd_sims[[sd]] <- multigroup.vaccine:::simulateOutbreaks(model,
                                                            R0 = R0, 
                                                            district_name = sd,
                                                            initmode = "random",
                                                            nsims = nsims)
  }
  hd_sims
}

health_district_risk_by_school_district <- function(hd_sims, model){
  sd_names <- paste0(names(hd_sims), " School District")
  
  sd_population <- sd_nonimmune <- sd_mean_inf <- sd_prob10 <- sd_prob100 <- rep(0, length(sd_names))
  for(i in seq_along(sd_names)){
    sd_info <- model$district_school_df[model$district_school_df$district == names(hd_sims)[i], ]
    sd_final_size <- rowSums(hd_sims[[i]]$final_size)
    nsims <- length(sd_final_size)
    sd_population[i] <- sum(sd_info$population)
    sd_nonimmune[i] <- sum(sd_info$population - round(sd_info$immune * sd_info$population))
    sd_mean_inf[i] <- mean(sd_final_size)
    sd_prob10[i] <- sum(sd_final_size >= 10) / nsims
    sd_prob100[i] <- sum(sd_final_size >= 100) / nsims
  }
  data.frame(school_district = sd_names,
             population = sd_population,
             nonimmune = sd_nonimmune,
             mean_infections = sd_mean_inf,
             prob_10plus_infections = sd_prob10,
             prob_100plus_infections = sd_prob100)
}

health_district_risk_by_group <- function(hd_sims, model){
  
  ngroups <- sum(model$district_school_df$district %in% names(hd_sims))
  
  school_district <- group <- population <- nonimmune <- mean_group_inf <- prob_group_init <- prob_group_inf <- rep(0, ngroups)
  ind <- 1L
  for(i in seq_along(hd_sims)){
    sim <- hd_sims[[i]]
    sd_info <- model$district_school_df[model$district_school_df$district == names(hd_sims)[i], ]
    inds <- ind:(ind + nrow(sd_info) - 1)
    
    school_district[inds] <- sd_info$district
    group[inds] <- sim$group_names
    population[inds] <- sd_info$population
    nonimmune[inds] <- sd_info$population - round(sd_info$population * sd_info$immune)
    nsims <- nrow(sim$final_size)
    mean_group_inf[inds] <- colSums(sim$final_size) / nsims
    prob_group_init[inds] <- tabulate(sim$init_group, ncol(sim$final_size)) / nsims
    prob_group_inf[inds] <- colSums(sim$final_size > 0) / nsims
    
    ind <- ind + nrow(sd_info)
  }
  data.frame(school_district = school_district,
             group = group,
             population = population,
             nonimmune = nonimmune,
             mean_infections = mean_group_inf,
             prob_group_init = prob_group_init,
             prob_group_inf = prob_group_inf)
}
```

## Example school district summary for Weber-Morgan Health District

``` r

hd_sims <- health_district_sims("Weber-Morgan", model, R0 = 7, nsims = 100000) 
school_district_risk <- health_district_risk_by_school_district(hd_sims, model)
school_district_risk
#>          school_district population nonimmune mean_infections
#> 1 Morgan School District      13384      1634        154.4676
#> 2  Ogden School District      91075     14254       1585.6672
#> 3  Weber School District     187097     23726       1364.4386
#>   prob_10plus_infections prob_100plus_infections
#> 1                0.30368                 0.25635
#> 2                0.31423                 0.25596
#> 3                0.25749                 0.19456
```

## Example group-specific summary for Weber-Morgan Health District

``` r

group_risk <- health_district_risk_by_group(hd_sims, model)
group_risk
#>     school_district         group population nonimmune mean_infections
#> 1            Morgan        under1        153       153         5.42216
#> 2            Morgan          1to4        574       170        10.98471
#> 3            Morgan    5to9_S0659        427        30         2.77056
#> 4            Morgan  10to13_S0657        514        43         5.94526
#> 5            Morgan    5to9_S0645        564       152        21.61780
#> 6            Morgan  10to13_S0642        501       101        18.56957
#> 7            Morgan  14to17_S0641       1184       181        32.37252
#> 8            Morgan   5to9_online         29        14         1.78174
#> 9            Morgan 10to13_online         35        10         1.67394
#> 10           Morgan 14to17_online         49        12         2.18309
#> 11           Morgan        18to21        906       134        13.70251
#> 12           Morgan        22to25        732       102         6.46440
#> 13           Morgan        26to29        505        65         3.84846
#> 14           Morgan        30to33        450        54         3.61010
#> 15           Morgan        34to37        506        56         3.90527
#> 16           Morgan        38to41        623        63         4.04665
#> 17           Morgan        42to45        802        73         5.54532
#> 18           Morgan        46to49        861        71         3.91446
#> 19           Morgan        50to53        628        46         2.57251
#> 20           Morgan        54to57        582        37         1.60308
#> 21           Morgan        58to61        499        27         0.91787
#> 22           Morgan        62to65        510        23         0.66976
#> 23           Morgan        66to69        485        17         0.34586
#> 24           Morgan           70+       1265         0         0.00000
#> 25            Ogden        under1       1101      1101        65.80799
#> 26            Ogden          1to4       4379      1231       116.24286
#> 27            Ogden   5to11_S1128         12         2         0.20440
#> 28            Ogden  12to14_S0881         71        10         1.29261
#> 29            Ogden   5to11_S0881        247        34         3.98197
#> 30            Ogden  12to14_S0744        194        49         7.55505
#> 31            Ogden   5to11_S0744        723       149        20.13659
#> 32            Ogden  15to17_S0736         23         6         0.96164
#> 33            Ogden  15to17_S0701        451        94        15.46899
#> 34            Ogden   5to11_S0545        376        84        11.65255
#> 35            Ogden  15to17_S0235        235        39         6.02845
#> 36            Ogden  12to14_S0235        343        19         2.21763
#> 37            Ogden   5to11_S0235        776       184        26.41579
#> 38            Ogden  12to14_S0736          2         0         0.00000
#> 39            Ogden   5to11_S1110        388        89        12.50835
#> 40            Ogden   5to11_S0910        602       156        23.24272
#> 41            Ogden   5to11_S1267        564       101        12.91498
#> 42            Ogden  15to17_S0743       1208       276        46.71289
#> 43            Ogden   5to11_S0741        528        67         7.72034
#> 44            Ogden   5to11_S0693        635       162        23.99848
#> 45            Ogden  12to14_S0652        853       147        20.46143
#> 46            Ogden  12to14_S0648        630       113        15.89578
#> 47            Ogden  15to17_S0583         44         6         0.85709
#> 48            Ogden   5to11_S0561        458        21         2.05707
#> 49            Ogden   5to11_S1021        555        65         7.33945
#> 50            Ogden   5to11_S0441        476        43         4.59873
#> 51            Ogden  12to14_S0433        657       102        13.83129
#> 52            Ogden   5to11_S0426        629        90        10.74432
#> 53            Ogden  15to17_S0378        241        56         9.43648
#> 54            Ogden   5to11_S0288        740        37         3.66603
#> 55            Ogden  15to17_S0075       1117       294        51.87529
#> 56            Ogden  15to17_S0714          5         1         0.12345
#> 57            Ogden   5to11_S0714          7         0         0.00000
#> 58            Ogden  15to17_S0512          7         2         0.28508
#> 59            Ogden  12to14_S0512          6         0         0.00000
#> 60            Ogden   5to11_S0512         26         6         0.74423
#> 61            Ogden  5to11_online        217       101        13.34797
#> 62            Ogden 12to14_online        107        34         4.77677
#> 63            Ogden 15to17_online        140        50         8.63280
#> 64            Ogden        18to21       5101      1146       164.02279
#> 65            Ogden        22to25       7291      1525       190.00946
#> 66            Ogden        26to29       7301      1413       164.02611
#> 67            Ogden        30to33       6519      1160       134.54275
#> 68            Ogden        34to37       5340       867        94.90175
#> 69            Ogden        38to41       4785       703        63.79680
#> 70            Ogden        42to45       4760       625        66.55148
#> 71            Ogden        46to49       4493       520        44.99240
#> 72            Ogden        50to53       3874       388        35.12908
#> 73            Ogden        54to57       3921       331        25.14310
#> 74            Ogden        58to61       3836       264        15.60184
#> 75            Ogden        62to65       3273       175         9.19597
#> 76            Ogden        66to69       3074       116         4.01615
#> 77            Ogden           70+       7734         0         0.00000
#> 78            Weber        under1       2364      2364        58.04938
#> 79            Weber          1to4       9403      2452       104.66067
#> 80            Weber  15to17_S1216          4         1         0.07461
#> 81            Weber  12to14_S1216          4         0         0.00000
#> 82            Weber   5to11_S1216         25         2         0.10698
#> 83            Weber  15to17_S1088        345        35         3.33025
#> 84            Weber  12to14_S1088        181        45         5.89539
#> 85            Weber   5to11_S1088        339        52         3.92452
#> 86            Weber  15to17_S1069        477        44         4.10605
#> 87            Weber  12to14_S1069        256        59         7.53433
#> 88            Weber   5to11_S0819        787       168        15.40498
#> 89            Weber  12to14_S0597        120        20         2.20213
#> 90            Weber   5to11_S0597        306        55         4.48450
#> 91            Weber  12to14_S0399        112         8         0.70727
#> 92            Weber   5to11_S0399         51         5         0.29854
#> 93            Weber   5to11_S0381        461       114        11.41573
#> 94            Weber   5to11_S0112        561        40         2.39319
#> 95            Weber   5to11_S1151        716       111         8.53950
#> 96            Weber   5to11_S1138        511       117        11.13514
#> 97            Weber  15to17_S1335       1585       412        55.92425
#> 98            Weber  15to17_S1126        321        38         3.76961
#> 99            Weber  15to17_S1125       1991       517        70.17391
#> 100           Weber   5to11_S1118        421        18         0.99507
#> 101           Weber  12to14_S1099       1053       185        21.49275
#> 102           Weber   5to11_S1085        295        11         0.59551
#> 103           Weber   5to11_S1080        565        45         2.74818
#> 104           Weber   5to11_S1056        579       153        16.12906
#> 105           Weber  15to17_S1049        172        29         3.18601
#> 106           Weber  12to14_S1014        566       142        19.03330
#> 107           Weber  12to14_S0942        827       121        13.13066
#> 108           Weber  12to14_S0929        279        52         6.09116
#> 109           Weber   5to11_S0919        605        52         3.24340
#> 110           Weber  12to14_S0898        691       142        17.50443
#> 111           Weber   5to11_S0874        409        16         0.87450
#> 112           Weber  12to14_S0873        980        90         8.59525
#> 113           Weber  15to17_S0872       1571        64         5.27097
#> 114           Weber   5to11_S0864        436        47         3.11636
#> 115           Weber  12to14_S0858        844        80         7.68296
#> 116           Weber   5to11_S0845        405        68         5.37253
#> 117           Weber   5to11_S0797        647        86         6.18053
#> 118           Weber   5to11_S0794        392        70         5.72244
#> 119           Weber  12to14_S0760       1039       205        24.90118
#> 120           Weber   5to11_S0756        461       110        10.72346
#> 121           Weber   5to11_S0711        488        28         1.60754
#> 122           Weber   5to11_S0709        538        51         3.26907
#> 123           Weber  12to14_S0708        883       141        15.79301
#> 124           Weber   5to11_S0682        318        63         5.42026
#> 125           Weber  12to14_S1329        898       236        32.38698
#> 126           Weber   5to11_S0610        525        98         8.24415
#> 127           Weber   5to11_S0582        704       109         8.35110
#> 128           Weber   5to11_S0571        451        72         5.58137
#> 129           Weber   5to11_S0531        385        68         5.52505
#> 130           Weber   5to11_S0502        803        43         2.45475
#> 131           Weber  15to17_S0449         30         7         0.77407
#> 132           Weber  12to14_S0449          7         1         0.07657
#> 133           Weber   5to11_S0448        512        43         2.67355
#> 134           Weber   5to11_S1326        550       110         9.62896
#> 135           Weber   5to11_S0409        391        21         1.19038
#> 136           Weber   5to11_S0395        537        86         6.70019
#> 137           Weber  15to17_S0367       1529       231        25.03227
#> 138           Weber   5to11_S0366        852        83         5.36717
#> 139           Weber   5to11_S0337        702       154        14.36357
#> 140           Weber   5to11_S0218        551        96         7.78413
#> 141           Weber   5to11_S0144         12         3         0.20085
#> 142           Weber   5to11_S0125        575        76         5.44340
#> 143           Weber  15to17_S0097       1391       230        25.74324
#> 144           Weber   5to11_S0063        723       120         9.50472
#> 145           Weber  5to11_online        564       233        18.86656
#> 146           Weber 12to14_online        292       100        12.03638
#> 147           Weber 15to17_online        378       103        12.17890
#> 148           Weber        18to21       9531      1575       101.99227
#> 149           Weber        22to25      11061      1708        77.05261
#> 150           Weber        26to29      11312      1625        70.13621
#> 151           Weber        30to33      10101      1342        63.07969
#> 152           Weber        34to37      10531      1285        60.77365
#> 153           Weber        38to41      10312      1146        47.99942
#> 154           Weber        42to45      10208      1024        51.11630
#> 155           Weber        46to49       9481       849        31.31171
#> 156           Weber        50to53       8176       643        24.15643
#> 157           Weber        54to57       7354       499        14.71830
#> 158           Weber        58to61       6685       381         8.81075
#> 159           Weber        62to65       7665       354         7.05812
#> 160           Weber        66to69       6896       244         3.31432
#> 161           Weber           70+      18038         0         0.00000
#>     prob_group_init prob_group_inf
#> 1           0.03123        0.32811
#> 2           0.06789        0.37305
#> 3           0.02000        0.29160
#> 4           0.04150        0.31274
#> 5           0.10436        0.38027
#> 6           0.09875        0.35486
#> 7           0.19543        0.42965
#> 8           0.00943        0.27695
#> 9           0.00989        0.27368
#> 10          0.01346        0.27790
#> 11          0.09412        0.38447
#> 12          0.05630        0.35422
#> 13          0.03321        0.32294
#> 14          0.02978        0.31627
#> 15          0.03094        0.31745
#> 16          0.02928        0.31633
#> 17          0.04416        0.33678
#> 18          0.03252        0.32033
#> 19          0.02303        0.30216
#> 20          0.01468        0.28658
#> 21          0.00853        0.26619
#> 22          0.00744        0.25099
#> 23          0.00407        0.19671
#> 24          0.00000        0.00000
#> 25          0.03267        0.33547
#> 26          0.06841        0.37660
#> 27          0.00014        0.14989
#> 28          0.00089        0.25601
#> 29          0.00260        0.26102
#> 30          0.00436        0.26283
#> 31          0.01177        0.27647
#> 32          0.00057        0.25115
#> 33          0.00909        0.27076
#> 34          0.00659        0.26778
#> 35          0.00392        0.26267
#> 36          0.00174        0.25867
#> 37          0.01564        0.28109
#> 38          0.00000        0.00000
#> 39          0.00721        0.26870
#> 40          0.01311        0.27730
#> 41          0.00790        0.27063
#> 42          0.02640        0.29563
#> 43          0.00547        0.26594
#> 44          0.01324        0.27692
#> 45          0.01239        0.27773
#> 46          0.00980        0.27264
#> 47          0.00059        0.25097
#> 48          0.00180        0.25916
#> 49          0.00532        0.26598
#> 50          0.00402        0.26321
#> 51          0.00896        0.27179
#> 52          0.00746        0.26923
#> 53          0.00513        0.26448
#> 54          0.00292        0.26220
#> 55          0.02750        0.29656
#> 56          0.00007        0.12345
#> 57          0.00000        0.00000
#> 58          0.00028        0.18712
#> 59          0.00000        0.00000
#> 60          0.00053        0.23786
#> 61          0.00840        0.27399
#> 62          0.00295        0.26248
#> 63          0.00481        0.26560
#> 64          0.09427        0.38569
#> 65          0.11964        0.42725
#> 66          0.10770        0.42412
#> 67          0.09449        0.40883
#> 68          0.06597        0.37371
#> 69          0.04187        0.34301
#> 70          0.04656        0.34549
#> 71          0.02964        0.32078
#> 72          0.02500        0.31035
#> 73          0.01808        0.29672
#> 74          0.01141        0.28369
#> 75          0.00717        0.27332
#> 76          0.00355        0.26366
#> 77          0.00000        0.00000
#> 78          0.03993        0.29484
#> 79          0.07855        0.34178
#> 80          0.00006        0.07461
#> 81          0.00000        0.00000
#> 82          0.00011        0.08577
#> 83          0.00233        0.19837
#> 84          0.00287        0.19842
#> 85          0.00285        0.19942
#> 86          0.00315        0.19967
#> 87          0.00385        0.20054
#> 88          0.00900        0.21107
#> 89          0.00140        0.19621
#> 90          0.00273        0.19981
#> 91          0.00047        0.19106
#> 92          0.00026        0.14970
#> 93          0.00666        0.20587
#> 94          0.00223        0.19895
#> 95          0.00597        0.20569
#> 96          0.00633        0.20579
#> 97          0.02737        0.23300
#> 98          0.00251        0.19828
#> 99          0.03452        0.24069
#> 100         0.00097        0.19491
#> 101         0.01199        0.21451
#> 102         0.00058        0.18693
#> 103         0.00247        0.19921
#> 104         0.00810        0.20864
#> 105         0.00193        0.19729
#> 106         0.00955        0.20851
#> 107         0.00747        0.20800
#> 108         0.00348        0.19965
#> 109         0.00273        0.19984
#> 110         0.00991        0.20981
#> 111         0.00075        0.19369
#> 112         0.00594        0.20493
#> 113         0.00424        0.20239
#> 114         0.00257        0.19934
#> 115         0.00497        0.20397
#> 116         0.00373        0.20182
#> 117         0.00467        0.20389
#> 118         0.00371        0.20123
#> 119         0.01285        0.21529
#> 120         0.00595        0.20497
#> 121         0.00154        0.19716
#> 122         0.00285        0.20012
#> 123         0.00920        0.21042
#> 124         0.00344        0.20044
#> 125         0.01529        0.21632
#> 126         0.00533        0.20402
#> 127         0.00610        0.20559
#> 128         0.00393        0.20205
#> 129         0.00355        0.20156
#> 130         0.00223        0.19911
#> 131         0.00038        0.18750
#> 132         0.00006        0.07657
#> 133         0.00218        0.19873
#> 134         0.00607        0.20554
#> 135         0.00102        0.19566
#> 136         0.00455        0.20313
#> 137         0.01626        0.22063
#> 138         0.00457        0.20349
#> 139         0.00807        0.21001
#> 140         0.00500        0.20411
#> 141         0.00015        0.11278
#> 142         0.00413        0.20217
#> 143         0.01558        0.21949
#> 144         0.00658        0.20721
#> 145         0.01241        0.22468
#> 146         0.00656        0.20814
#> 147         0.00657        0.20929
#> 148         0.07309        0.31763
#> 149         0.07125        0.32760
#> 150         0.06633        0.32698
#> 151         0.06041        0.31558
#> 152         0.05607        0.30951
#> 153         0.04181        0.28682
#> 154         0.04528        0.28796
#> 155         0.02720        0.25945
#> 156         0.02382        0.24978
#> 157         0.01651        0.23393
#> 158         0.00945        0.21796
#> 159         0.00939        0.21577
#> 160         0.00408        0.20410
#> 161         0.00000        0.00000
```
