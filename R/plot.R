globalVariables(c(".", "resource", "end_time", "start_time", "duration"))


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


#' Plot shimmer resource usage
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

#' Plot shimmer cpu usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_cpu_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[.$resource == "cpu", ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server", "queue")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "bottom") +
    ggplot2::ggtitle("CPU usage")
}


#' Plot shimmer connection usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_connection_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[.$resource %in% c("connection"), ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "bottom") +
    ggplot2::ggtitle("Connection usage")

}

#' Plot shimmer rejections
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_rejection_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[.$resource %in% c("rejections"), ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "bottom") +
    ggplot2::ggtitle("Cumulative rejected connections")

}


#' Plot shimmer process usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_process_usage <- function(.env){
  .env %>%
    get_mon_resources() %>%
    .[grepl("^process", .$resource), ] %>%
    plot(metric = "usage",
         steps = FALSE,
         items = c("server")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "bottom") +
    ggplot2::ggtitle("Process usage")

}


#' Plot histogram of CPU response times
#'
#' @inheritParams plot_shimmer_resources
#' @param binwidth Passed to [ggplot2::geom_histogram()]
#'
#' @export
#' @family plot functions
#'
plot_shimmer_response_histogram <- function(.env, binwidth = 0.1){
  .env %>%
    get_mon_arrivals(per_resource = TRUE) %>%
    dplyr::filter(resource == "cpu") %>%
    dplyr::mutate(duration = end_time - start_time) %>%
    ggplot(aes_string(x = "duration")) +
    geom_histogram(binwidth = binwidth) +
    ggplot2::ggtitle("Response time")
}
