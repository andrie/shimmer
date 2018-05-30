#' Alternative formulation of rgamma function, supplying  mean and shape.
#'
#' Refer to the help for [rgamma()] for the meaning of `shape` and `scale`.
#'
#' @param mean mean
#' @param shape shape
#'
#' @export
agamma <- function(n, mean, shape){
  scale <- mean / shape
  rgamma(n, shape = shape, scale = scale)
}
