## dependencies
require(deSolve)
require(shiny)
## dependent functions
library(shiny)
library(bslib)

#' @import shiny

library(bslib)

double_input_row <- function(input_ida, input_idb, label, valuea, valueb) {
  tags$tr(
    tags$td(label),
    tags$td(numericInput(inputId = input_ida, value = valuea, label = NULL, width = "100px", )),
    tags$td(numericInput(inputId = input_idb, value = valueb, label = NULL, width = "100px", ))
  )
}

single_input_row <- function(input_id, label, value) {
  tags$tr(
    tags$td(label),
    tags$td(numericInput(inputId = input_id, value = value, label = NULL, width = "100px"))
  )
}

ui <- page_fluid(gap = 0,
  tags$head(tags$style(
    "table {font-size: 8pt;
                       border-collapse: collapse;
                       compact; nowrap;}
                       th, tr, td {padding: 0px;
                               border-spacing: 0px;
                               margin: 0px;
                       }
                       shiny-input-number{
                          padding-block: 0px;
                          padding-inline: 0px;
                       }"
  )),
  theme = bslib::bs_theme(version = 5, bootswatch = "pulse"),
  titlePanel("Vaccine Strategies in Disparate Populations"),
  layout_column_wrap(
    width = "250px",
    card(
      tags$table(
        tags$tr(
          tags$th(colspan = 3,
            "Population Setup"
          )
        ),
        tags$tr(
          tags$td(""),
          tags$th("Population A"),
          tags$th("Population B")

        ),
        double_input_row("popsize_a", "popsize_b", "Population Size", 80000, 20000),
        double_input_row("vacPortion_a", "vacPortion_b", "Fraction Vaccinated", 0.1, 0.1),
        double_input_row("contactWithinGroup_a", "contactWithinGroup_b", "Contact Rate", 100, 100)
      )
    ),
    card(
      card_title("Parameters"),
      tags$table(
        single_input_row("vacTime", "Vaccination time", 100),
        single_input_row("recoveryRate", "Recovery Rate", 0.1),
        single_input_row("R0", "R0", 1.2),
        single_input_row("amountToSpend", "Amount to spend", 1e5),


      )
    ),
    card(
      card_title("Population Ratios"),
      tags$table(

        single_input_row("contactRatio", "Contact Ratio", 1.2),
        single_input_row("suscRatio", "Susceptibility Ratio", 1.2),
        single_input_row("vaccineCostRatio", "Vaccine cost ratio", 1.2)

      )
    )
  ),
  plotOutput("plot", click = "plot_click", ),

  absolutePanel(bottom = 0, left = 0, right = 0, fixed = TRUE,
    img(src = "figs/logo.jpg", align = "right", height = 100, width = 100)
  )
)
