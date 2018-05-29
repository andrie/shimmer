if (interactive()) library(testthat)

context("simmer_shiny")

test_that("simmer_shiny() returns an env", {

  conf_file <- system.file("config.yml", package = "simmer.shiny")
  expect_true(file.exists(conf_file))

  y <- yaml::read_yaml(conf_file)
  expect_is(y, "list")

  z <- simmer_shiny(0)
  expect_is(z, "simmer")

  z <- simmer_shiny(100)
  expect_is(z, "simmer")
})


test_that("plotting simmer_shiny() returns ggplot objects", {
  z <- simmer_shiny(100)

  r <- simmer::get_mon_resources(z)
  expect_is(r, "data.frame")

  p <- plot_shiny_resources(z)
  expect_is(p, "ggplot")

  p <- plot_shiny_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shiny_cpu_histogram(z)
  expect_is(p, "ggplot")


})
