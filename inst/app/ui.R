## dependencies
require(deSolve)
require(shiny)
## dependent functions
library(shiny)
library(bslib)

#' @import shiny

library(bslib)

myToolTip <- function(tipText = NULL) {
  if (!is.null(tipText)) {
    return(
      tooltip(
        img(src = "figs/tooltip.png", height = 20, width = 20),
        tipText
      )
    )
  }
}

double_input_row <- function(input_ida, input_idb, label, valuea, valueb, tip = NULL) {
  tags$tr(
    tags$td(
      myToolTip(tip),
      label
    ),
    tags$td(numericInput(inputId = input_ida, value = valuea, label = NULL, width = "100px")),
    tags$td(numericInput(inputId = input_idb, value = valueb, label = NULL, width = "100px"))
  )
}

single_input_row <- function(input_id, label, value, tip = NULL) {
  tags$tr(
    tags$td(myToolTip(tip),
      label),
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
  navset_tab(
    nav_panel("Model",


      layout_column_wrap(
        width = "250px",
        card(
          card_title("Population Setup"),
          tags$table(
            tags$tr(
              tags$td(""),
              tags$th("Population A"),
              tags$th("Population B")

            ),

            double_input_row("popsize_a", "popsize_b", "Population Size", 80000, 20000, tip = "Size of each population"),
            double_input_row("vacPortion_a", "vacPortion_b", "Fraction Vaccinated", 0.1, 0.1, tip = "Fraction of each population that is vaccinated at time zero."),
            double_input_row("contactWithinGroup_a", "contactWithinGroup_b", "Fraction of contacts within-group", 0.4, 0.4, tip = "This is the propotion of contacts made by individuals in each population that are within their own group."),
          )
        ),
        card(
          card_title("Parameters"),
          tags$table(
            single_input_row("vacTime", "Vaccination time", 0, tip = "Time when vaccine will be started"),
            single_input_row("recoveryRate", "Recovery Rate", 0.1, tip = "Probability per day of a infected individual recovering"),
            single_input_row("R0", "R0", 1.2, tip = "duh"),
            single_input_row("amountToSpend", "Amount to spend", 1e5, tip = "Funds available for vacination ($)"),


          )
        ),
        card(
          card_title("Population Ratios"),
          tags$table(

            single_input_row("contactRatio", "Contact Ratio", 1.1),
            single_input_row("suscRatio", "Susceptibility Ratio", 1.2),
            single_input_row("vaccineCostRatio", "Vaccine cost ratio", 1.3)

          )
        )
      ),
      plotOutput("plot", click = "plot_click", ),
    ),
    nav_panel("About")),


  absolutePanel(bottom = 0, left = 0, right = 0, fixed = TRUE,
    img(src = "figs/logo.jpg", align = "right", height = 100, width = 100)
  )
)
