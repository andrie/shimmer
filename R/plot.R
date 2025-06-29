globalVariables(
  c(
    ".",
    "resource",
    "end_time",
    "start_time",
    "duration",
    "replication",
    "time",
    "util",
    "cum_util",
    "capacity",
    "server"
  )
)


#' Plot shiny resources
#'
#' @param .env A `simmer` environment, as defined by [shimmer()]
#'
#' @export
#' @family plot functions
#'
plot_shimmer_resources <- function(.env) {
  assert_is_simmer(.env)
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
plot_shimmer_usage <- function(.env) {
  assert_is_simmer(.env)
  .env %>%
    get_mon_resources() %>%
    .[.$resource != "connection_request", ] %>%
    plot(metric = "usage", steps = FALSE, items = c("server", "queue")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(legend.position = "none")
}

#' Plot shimmer cpu usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
#' @importFrom ggplot2 geom_line stat_smooth scale_y_continuous ylab ggtitle geom_point
#'
plot_shimmer_cpu_usage <- function(.env) {
  assert_is_simmer(.env)
  .env %>%
    fast_server_usage_summary("cpu") %>%
    ggplot(aes(x = time, y = util)) +
    geom_point(col = "grey50", size = 0.5, alpha = 0.1) +
    stat_smooth(method = "gam", formula = y ~ s(x, bs = "cs", k = 50)) +
    scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
    ylab("Utilisation") +
    ggtitle("CPU usage")
}


#' Plot shimmer connection usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_connection_usage <- function(.env) {
  assert_is_simmer(.env)
  .env %>%
    get_mon_resources() %>%
    .[.$resource %in% c("connection"), ] %>%
    plot(metric = "usage", steps = TRUE, items = c("server")) +
    theme(
      legend.position = "none",
      strip.text.x = ggplot2::element_blank()
    ) +
    ggplot2::ggtitle("Active connections")
}

#' Plot shimmer rejections
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_rejection_usage <- function(.env) {
  assert_is_simmer(.env)
  resources <- .env %>%
    get_mon_resources()

  rejections <- resources %>%
    .[.$resource %in% c("rejections"), ]

  if (nrow(rejections) == 0) {
    connections <- resources %>%
      .[.$resource %in% c("total_connections"), ]
    connections <- connections[c(1, nrow(connections)), ]
    connections$resource <- "rejections"
    connections$server <- 0
    connections$system <- 0
    rejections <- connections
  }

  rejections <- rbind(
    rejections[1, ],
    rejections
  )

  rejections[1, "time"] <- 0
  rejections[1, "server"] <- 0
  rejections[1, "system"] <- 0

  p <- rejections %>%
    plot(metric = "usage", steps = TRUE, items = c("server")) +
    theme(
      legend.position = "none",
      strip.text.x = ggplot2::element_blank()
    ) +
    ggplot2::ggtitle("Rejected connections", subtitle = "Cumulative")

  if (max(rejections$server) <= 10) {
    p <- p + ggplot2::scale_y_continuous(breaks = 0:10, limits = c(0, 10))
  }
  p
}


#' Plot shimmer process usage
#'
#' @inheritParams plot_shimmer_resources
#'
#' @export
#' @family plot functions
#'
plot_shimmer_process_usage <- function(.env) {
  assert_is_simmer(.env)
  resources <- .env %>%
    get_mon_resources() %>%
    .[grepl("^process", .$resource), ]

  resources$resource <- gsub("process_", "", resources$resource)
  levels <- sort(unique(as.numeric(resources$resource)))

  resources$resource <- factor(resources$resource, levels = levels)

  resources %>%
    plot(metric = "usage", steps = TRUE, items = c("server")) +
    facet_grid(resource ~ ., scales = "free_y") +
    theme(
      legend.position = "none",
      strip.text.y = ggplot2::element_text(angle = 0)
    ) +
    ggplot2::ggtitle("Connections per process")
}


#' Plot histogram of CPU response times
#'
#' @inheritParams plot_shimmer_resources
#' @param binwidth Passed to [ggplot2::geom_histogram()]
#'
#' @export
#' @family plot functions
#'
plot_shimmer_response_histogram <- function(.env, binwidth = 0.1) {
  assert_is_simmer(.env)
  .env %>%
    get_mon_arrivals(per_resource = TRUE) %>%
    dplyr::filter(resource == "cpu") %>%
    dplyr::mutate(duration = end_time - start_time) %>%
    ggplot(aes_string(x = "duration")) +
    geom_histogram(binwidth = binwidth) +
    ggplot2::ggtitle("Response time")
}

compute_duration_ratio <- function(.env, expected) {
  assert_is_simmer(.env)
  assert_that(is.numeric(expected))
  .env %>%
    get_mon_arrivals(per_resource = TRUE) %>%
    dplyr::filter(resource == "cpu") %>%
    dplyr::mutate(
      duration = end_time - start_time,
      in_time = duration <= expected
    ) %>%
    dplyr::summarize(
      ratio = sum(in_time) / length(in_time)
    ) %>%
    .[["ratio"]]
}
