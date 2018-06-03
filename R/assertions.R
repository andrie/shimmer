
assert_is_simmer <- function(x){
  assert_that(inherits(x, "simmer"), msg = "input must be a simmer object")
}
