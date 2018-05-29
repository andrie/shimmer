#' Runs example shiny app
#'
#' @export
run_example <- function() {
  app_dir <- system.file("shiny-examples", "shimmer", package = "shimmer")
  if (app_dir == "") {
    stop("Could not find example directory. Try re-installing `shimmer`.", call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
