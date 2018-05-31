#' Alternative formulation of rgamma function, supplying  mean and shape.
#'
#' Refer to the help for [rgamma()] for the meaning of `shape` and `scale`.
#'
#' @param n Number of observations, passed to [rgamma()]
#' @param mean mean
#' @param shape shape
#'
#' @export
agamma <- function(n, mean, shape){
  # a = shape
  # s = scale
  # m = a*s  thus  s = m/a

  scale <- mean / shape
  stats::rgamma(n, shape = shape, scale = scale)
}
