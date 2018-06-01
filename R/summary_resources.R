#' @importFrom utils tail
last_resource_value <- function(.env, name){
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
