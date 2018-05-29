#' Plot shiny resources
#'
#' @param .env A `simmer` environment, as defined by [simmer_shiny()]
#'
#' @export
#' @family plot functions
#'
plot_shiny_resources <- function(.env){
  .env %>%
    get_mon_resources() %>%
  plot(metric = "utilization")
}

#' Plot shiny usage
#'
#' @inheritParams plot_shiny_resources
#'
#' @export
#' @family plot functions
#'
plot_shiny_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[.$resource != "connection_request", ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server", "queue")) +
    facet_grid(resource ~ ., scales = "free_y")
}



#' Plot histogram of CPU response times
#'
#' @inheritParams plot_shiny_resources
#'
#' @export
#' @family plot functions
#'
plot_shiny_cpu_histogram <- function(.env, binwidth = 0.1){
  .env %>%
    get_mon_arrivals(per_resource = TRUE) %>%
    dplyr::filter(resource == "cpu") %>%
    dplyr::mutate(duration = end_time - start_time) %>%
    ggplot(aes(x = duration)) +
    geom_histogram(binwidth = binwidth)
}
