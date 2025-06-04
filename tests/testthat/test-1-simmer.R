if (interactive()) library(testthat)

context("shimmer")

test_that("shimmer() returns an env", {
  conf_file <- shimmer_config_file()
  expect_true(file.exists(conf_file))

  y <- yaml::read_yaml(conf_file)
  expect_is(y, "list")

  set.seed(1)
  z <- shimmer(0)
  expect_is(z, "simmer")

  set.seed(1)
  z <- shimmer(100)
  expect_is(z, "simmer")

  set.seed(1)
  z <- shimmer(100, config_file = conf_file)
  expect_is(z, "simmer")

  set.seed(1)
  z <- shimmer(100, config = yaml::read_yaml(conf_file)$default)
  expect_is(z, "simmer")
})


test_that("plotting shimmer() returns ggplot objects", {
  set.seed(1)
  z <- shimmer(100)

  expect_true(assert_is_simmer(z))

  r <- simmer::get_mon_resources(z)
  expect_is(r, "data.frame")

  p <- plot_shimmer_connection_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shimmer_cpu_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shimmer_process_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shimmer_rejection_usage(z)
  expect_is(p, "ggplot")

  p <- plot_shimmer_resources(z)
  expect_is(p, "ggplot")

  p <- plot_shimmer_usage(z)
  expect_is(p, "ggplot")
})
