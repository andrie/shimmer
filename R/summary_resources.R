#' @importFrom utils tail
last_resource_value <- function(.env, name) {
  res <- .env %>%
    get_mon_resources() %>%
    .[.$resource == name, "server"]
  if (length(res) == 0) 0 else tail(res, 1)
}

#' Extract summary value
#'
#' @param .env A `simmer` environment, as defined by [shimmer()]
#'
#' @export
#' @family plot functions
#'
summary_cpu <- function(.env) last_resource_value(.env, "cpu")




# plot.resources.usage <- function(x, items = c("system", "queue", "server"), steps = FALSE) {
#   items <- match.arg(items, several.ok = TRUE)
#
#   limits <- x %>%
#     dplyr::mutate(
#       server = .data$capacity, queue = .data$queue_size,
#       system = .data$limit
#     ) %>%
#     tidyr::gather("item", "value", c("server", "queue", "system")) %>%
#     dplyr::mutate(item = factor(.data$item)) %>%
#     dplyr::filter(.data$item %in% items)
#
#   x <- x %>%
#     tidyr::gather("item", "value", c("server", "queue", "system")) %>%
#     dplyr::mutate(item = factor(.data$item)) %>%
#     dplyr::filter(.data$item %in% items) %>%
#     dplyr::group_by(
#       .data$resource,
#       .data$replication,
#       .data$item
#     ) %>%
#     dplyr::mutate(
#       mean = c(0, cumsum(utils::head(.data$value, -1) * diff(.data$time))) / .data$time
#     ) %>%
#     dplyr::ungroup()
#
#   plot_obj <- ggplot(x, aes_(x = ~ time, color = ~ item)) +
#     facet_grid(~ resource) +
#     geom_step(aes_(y = ~ value, group = ~ interaction(replication, item)), limits, lty = 2) +
#     ggtitle(paste("Resource usage")) +
#     ylab("in use") +
#     xlab("time") +
#     expand_limits(y = 0)
#
#   if (steps == TRUE) {
#     plot_obj <- plot_obj +
#       geom_step(aes_(y = ~ value, group = ~ interaction(replication, item)), alpha = set_alpha(x))
#   } else {
#     plot_obj <- plot_obj +
#       geom_line(aes_(y = ~ mean, group = ~ interaction(replication, item)), alpha = set_alpha(x))
#   }
#   plot_obj
# }

#' Rapidly computes a resource usage summary.
#'
#' @inheritParams plot_shimmer_resources
#' @param name Resource name, e.g. "cpu"
#' @param If TRUE, returns the overall mean utilization, i.e. the last row of
#'   compuation
#'
#' @export
fast_server_usage_summary <- function(.env, name, summarize = FALSE) {

  p <- .env %>%
    simmer.plot::get_mon_resources() %>%
    dplyr::filter(resource == name) %>%
    dplyr::select(dplyr::one_of(c("replication", "time", "server", "capacity"))) %>%
    dplyr::group_by(replication) %>%
    dplyr::mutate(
      difftime = c(0, diff(time)),
      util = server / capacity,
      cum_util = cumsum(util * difftime) / time
    )

  if (summarize) p <- p %>%
    dplyr::summarize(mean = tail(cum_util, 1))

  p %>%
    dplyr::ungroup()

}
