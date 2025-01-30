#' Runs the vaccine model
#' @export
run_model <- function() {
  shinyApp(ui, server)
}
