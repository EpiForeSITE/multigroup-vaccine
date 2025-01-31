## dependencies
require(deSolve)
require(shiny)
## dependent functions
library(shiny)
library(bslib)

#' @import shiny

library(bslib)


ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "minty"),

  titlePanel("Vaccine Equity"),




  bslib::layout_column_wrap(width = 1 / 3,
    card(bslib::layout_column_wrap(width = 1 / 2),
      "Population A",

      textInput(inputId = "vacPortion_a", label = "fraction vaccinated", value = "0.1", width = "10%")
    ),
    card("Ratios"),
    card("Population B")
  )









)








#
#
# ## shiny app
# ui <- fixedPage(
#   titlePanel("Model Title"),
#   img(src = "figs/logo.jpg", align = "right", height = 100, width = 100),
#
#   fluidRow(
#     textInput2("vacPortion_a", label = "fraction vaccinated a = ", value = "0.1", class = "input-small"),
#
#     textInput2("vacPortion_b", label = "fraction vaccinated b = ", value = "0.1", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("vacTime", label = "time after first case at which all vaccinations are delivered = ", value = "100", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("popSize_a", label = "a popsize = ", value = "800000", placeholder = "", class = "input-small"),
#     textInput2("popSize_b", label = "b popsize = ", value = "200000", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("R0", label = "overall basic reproduction number = ", value = "1.5", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("recoveryRate", label = "inverse of mean infectious period = ", value = "0.14", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#
#     textInput2("contactRatio", label = "ratio of 2nd group's : 1st group's overall contact rate = ", value = "1.7", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("contactWithinGroup_a", label = "within a group mixing fraction = ", value = "0.4", placeholder = "", class = "input-small"),
#     textInput2("contactWithinGroup_b", label = "within b group mixing fraction = ", value = "0.4", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("suscRatio", label = "ratio of 2nd group's : 1st group's susceptibility to infection per contact = ", value = "1", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("amountToSpend", label = "amount available to spend on vaccine rollout = ", value = "1e5", placeholder = "", class = "input-small"),
#   ),
#   fluidRow(
#     textInput2("vaccineCostRatio", label = "ratio of 2nd group's : 1st group's per-individual cost to vaccinate = ", value = "1", placeholder = "", class = "input-small"),
#   ),
#   # "then R0 = ", textOutput("r0",inline=T),
#   # ", total people infected = ", textOutput("infs",inline=T),
#   # ", and vaccine doses given = ", textOutput("vaxs",inline=T),
#
#   plotOutput("plot", click = "plot_click", )
#
# )
