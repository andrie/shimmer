#' @name miniCRAN-package
#' @aliases miniCRAN minicran
#' @docType package
#'
#' @importFrom config get
#' @importFrom assertthat assert_that
#' @importFrom magrittr %>%
#'
#' @importFrom simmer simmer select seize seize_selected release release_selected
#' @importFrom simmer trajectory timeout branch rollback log_ join get_n_activities
#' @importFrom simmer add_resource add_generator set_capacity at run
#'
#' @importFrom simmer.plot get_mon_resources get_mon_arrivals
#'
#' @importFrom ggplot2 ggplot aes geom_histogram facet_grid
#'
"_PACKAGE"
