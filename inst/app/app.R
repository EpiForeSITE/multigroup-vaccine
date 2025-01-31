#' Runs the vaccine model
#'
#'


#' @export
run_model <- function() {
  shinyAppDir(
    system.file("app/", package = "vaccine.equity")
  )
}
