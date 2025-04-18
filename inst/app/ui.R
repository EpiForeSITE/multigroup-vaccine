## dependencies
require(deSolve)
require(shiny)
## dependent functions
library(shiny)
library(bslib)
library(shinya11y)


#' @import shiny

library(bslib)

myToolTip <- function(tipText = NULL, id = NULL) {
  if (!is.null(tipText)) {
    return(tooltip(img(
      src = "figs/tooltip.png",
      height = 20,
      width = 20,
      alt = tipText
    ),
    tags$label(tipText)
    ))


  }
}

double_input_row <- function(input_ida,
                             input_idb,
                             label,
                             valuea,
                             valueb,
                             tip = NULL) {
  tags$tr(
    tags$td(myToolTip(tip), label),
    tags$td(
      numericInput(
        inputId = input_ida,
        value = valuea,
        label = NULL,
        width = "100px"
      )
    ),
    tags$td(
      numericInput(
        inputId = input_idb,
        value = valueb,
        label = NULL,
        width = "100px"
      )
    )
  )
}

single_input_row <- function(input_id, label, value, tip = NULL) {
  tags$tr(tags$td(myToolTip(tip), label), tags$td(
    numericInput(
      inputId = input_id,
      value = value,
      label = NULL,
      width = "100px"
    )
  ))
}

ui <- page_fluid(
  use_tota11y(),
  gap = 0,
  tags$head(
    tags$style(
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
    )
  ),
  theme = bslib::bs_theme(version = 5, bootswatch = "pulse"),
  titlePanel("Vaccine Strategies in Disparate Populations"),
  navset_tab(
    nav_panel(
      "Model",
      layout_column_wrap(
        width = "250px",
        card(
          card_title("Population Setup"),
          tags$table(
            tags$tr(tags$td(""), tags$th("Group A"), tags$th("Group B")),
            double_input_row("popsize_a", "popsize_b", "Population Size", 80000, 20000, tip = "Size of each population"),
            double_input_row(
              "vacPortion_a",
              "vacPortion_b",
              "Fraction Vaccinated",
              0.3,
              0.2,
              tip = "Fraction of each population that is vaccinated at time zero."
            ),
            double_input_row(
              "contactWithinGroup_a",
              "contactWithinGroup_b",
              "Fraction of contacts within-group",
              0.4,
              0.4,
              tip = "This is the propotion of contacts made by individuals in each population that are within their own group."
            ),
            double_input_row(
              "hospProb_a",
              "hospProb_b",
              "Hospitilization probability",
              0.017,
              0.032,
              tip = "The fraction of infected individuals who are hospitilized due to the infection."
            ),
            double_input_row(
              "hospDeathProb_a",
              "hospDeathProb_b",
              "Death probability among hospitalized",
              0.25,
              0.25,
              tip = "The fraction of infected, hospitalilized individuals who die from the infection."
            ),
            double_input_row(
              "nonHospDeathProb_a",
              "nonHospDeathProb_b",
              "Death probability among non-hospitalized",
              0.00055,
              0.00055,
              tip = "The fraction of infected, non-hospitalilized individuals who die from the infection."
            )
          )
        ),
        card(
          card_title("Parameters"),
          tags$table(
            single_input_row("vacTime", "Vaccination start time (days)", 0, tip = "Time when vaccine will be started"),
            single_input_row("recoveryRate", "Recovery Rate", 0.1, tip = "Probability per day of a infected individual recovering"),
            single_input_row("R0", "R0", 2, tip = "Basic Reproduction Number"),
            single_input_row("contactRatio", "Contact Ratio", 1.1, tip = "The ratio of the contact rate of the second group to the first group"),
            single_input_row("suscRatio", "Susceptibility Ratio", 1.2,
              tip =
                "The ratio of the susceptibility of the second group to the first group"
            )
            # ,single_input_row("vaccineCostRatio", "Vaccine cost ratio", 1.3, tip =
            #  "The ratio of the cost of the vaccine for the second group to the first group")
            # ,single_input_row("amountToSpend", "Amount to spend", 1e5, tip = "Funds available for vacination ($)")
          )
        ),
        card(
          card_title("Output"),
          tableOutput("table"),
        )
      ),
      # plotOutput("plot", click = "plot_click", ),
    ),
    nav_panel(
      "About",
      h3("Abstract:"),
      p(
        "Addressing disparities in vaccine uptake through targeted outreach programs requires additional funding, but the cost and outcome trade-offs are not well-understood. This study compared the overall and distributional health and cost outcomes of different vaccination programs."
      ),
      tags$i("D. Nguyen1 ∙ K. Duong2 ∙ E. Coates3 ∙ R.E. Nelson4 ∙ J. Love4 ∙ M.M. Jones4 ∙ M. Samore5 ∙ N. Chaiyakunapruk6 ∙ D. Toth"),
      a("https://doi.org/10.1016/j.jval.2024.03.039", href = "https://doi.org/10.1016/j.jval.2024.03.039", class = "link-class", id = "paper_link"),
      br(), br(),
      p("This project was made possible by cooperative agreement CDC-RFA-FT-23-0069 from the CDC’s Center for Forecasting and Outbreak Analytics. Its contents are solely the responsibility of
        the authors and do not necessarily represent the official views of the Centers for Disease Control and Prevention.")
    )
  ),
  absolutePanel(
    bottom = 0,
    left = 0,
    right = 0,
    fixed = TRUE,
    img(
      src = "figs/logo.jpg",
      align = "left",
      height = 100,
      width = 100
    )
  )
)
