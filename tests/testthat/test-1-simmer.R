if (interactive()) library(testthat)

context("shimmer")

test_that("shimmer() returns an env", {

  conf_file <- shimmer_config_file()
  expect_true(file.exists(conf_file))

  y <- yaml::read_yaml(conf_file)
  expect_is(y, "list")

  z <- shimmer(0)
  expect_is(z, "simmer")

  z <- shimmer(100)
  expect_is(z, "simmer")

  z <- shimmer(100, config_file = conf_file)
  expect_is(z, "simmer")


  z <- shimmer(100, config = yaml::read_yaml(conf_file)$default )
  expect_is(z, "simmer")


})


test_that("plotting shimmer() returns ggplot objects", {
  z <- shimmer(100)

  r <- simmer::get_mon_resources(z)
  expect_is(r, "data.frame")

  p <- plot_shiny_resources(z)
  expect_is(p, "ggplot")

  p <- plot_shiny_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shiny_cpu_histogram(z)
  expect_is(p, "ggplot")


})


