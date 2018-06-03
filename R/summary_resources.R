#' Extracts last available value of a resource
#'
#' @importFrom utils tail

#' @inheritParams plot_shimmer_resources
#' @param name Resource name, e.g. "cpu"
#'
#' @export
#' @family resource summary functions
last_resource_value <- function(.env, name) {
  res <- .env %>%
    get_mon_resources() %>%
    .[.$resource == name, "server"]
  if (length(res) == 0) 0 else tail(res, 1)
}



#' Rapidly computes a resource usage summary.
#'
#' @inheritParams plot_shimmer_resources
#' @inheritParams last_resource_value
#'
#' @param summarize If TRUE, returns the overall mean utilization, i.e. the last row of
#'   compuation

#' @family resource summary functions
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
