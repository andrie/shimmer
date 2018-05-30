#' Plot shiny resources
#'
#' @param .env A `simmer` environment, as defined by [shimmer()]
#'
#' @export
#' @family plot functions
#'
plot_shimmer_resources <- function(.env){
  .env %>%
    get_mon_resources() %>%
  plot(metric = "utilization")
}

globalVariables(c(".", "resource", "end_time", "start_time", "duration"))

#' Plot shiny usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
#' @importFrom ggplot2 theme facet_grid
#' @importFrom graphics plot
#'
plot_shimmer_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[.$resource != "connection_request", ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server", "queue")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "bottom")
}



#' Plot histogram of CPU response times
#'
#' @inheritParams plot_shimmer_resources
#' @param binwidth Passed to [ggplot2::geom_histogram()]
#'
#' @export
#' @family plot functions
#'
plot_shimmer_cpu_histogram <- function(.env, binwidth = 0.1){
  .env %>%
    get_mon_arrivals(per_resource = TRUE) %>%
    dplyr::filter(resource == "cpu") %>%
    dplyr::mutate(duration = end_time - start_time) %>%
    ggplot(aes_string(x = "duration")) +
    geom_histogram(binwidth = binwidth)
}
