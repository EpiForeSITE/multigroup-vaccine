## dependencies
require(deSolve)
require(shiny)
## dependent functions
library(shiny)
library(bslib)

#' @import shiny

library(bslib)


ui <- bslib::page_fluid(gap = 0,
  tags$head(tags$style(
    "table {font-size: 10pt;
    border-collapse: collapse;
    compact; nowrap;}
    th, tr, td {padding: 0px;
            border-spacing: 0px;
            margin: 0px;}"
  )),
  theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
  h3("Application Title"),
  layout_column_wrap(
    width = "250px",
    card(
      card_header("Population A"),
      tags$table(
        tags$tr(
          tags$td(p("Population Size")),
          tags$td(numericInput(inputId = "popsize_a", value = 80000, label = "", width = "100px"))
        ),
        tags$tr(
          tags$td(p("Fraction Vaccinated")),
          tags$td(numericInput(inputId = "vac_portion_a", value = 0.1, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Contact Rate"),
          tags$td(numericInput(inputId = "contact_rate_a", value = 100, label = "", width = "100px"))
        )
      ),
      full_screen = TRUE
    ),
    card(
      card_header("Ratios"),
      tags$table(
        tags$tr(
          tags$td("Vaccination time"),
          tags$td(numericInput(inputId = "Vaccination_time", value = 100, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Recovry Rate"),
          tags$td(numericInput(inputId = "recovery_rate", value = 0.1, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("R0"),
          tags$td(numericInput(inputId = "r0", value = 1.2, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Amount to spend"),
          tags$td(numericInput(inputId = "amount_to_spend", value = 1e5, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Contact Ratio"),
          tags$td(numericInput(inputId = "contact_ratio", value = 1.2, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Susceptibility Ratio"),
          tags$td(numericInput(inputId = "susc_ratio", value = 1.2, label = "", width = "100px"))

        ),
        tags$tr(
          tags$td("Vaccine cost ratio"),
          tags$td(numericInput(inputId = "cost_ratio", value = 1.2, label = "", width = "100px"))

        )

      ),

      full_screen = TRUE
    ),
    card(
      card_header("Population B"),
      tags$table(
        tags$tr(
          tags$td(p("Population Size")),
          tags$td(numericInput(inputId = "popsize_a", value = 80000, label = "", width = "100px"))
        ),
        tags$tr(
          tags$td(p("Fraction Vaccinated")),
          tags$td(numericInput(inputId = "vac_portion_a", value = 0.1, label = "", width = "100px"))
        ),

        tags$tr(
          tags$td("Contact Rate"),
          tags$td(numericInput(inputId = "contact_rate_a", value = 100, label = "", width = "100px"))
        )
      ),
      full_screen = TRUE
    )
  ),
  absolutePanel(bottom = 0, left = 0, right = 0, fixed = TRUE,
    img(src = "figs/logo.jpg", align = "right", height = 100, width = 100)
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
