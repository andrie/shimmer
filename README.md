
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shimmer <img src="man/figures/logo_small.png" align="right" />

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

The `shimmer` package contains a discrete event simulation that explores
how `shiny` processes behave at scale, typically orchestrated by
*RStudio Connect* or *Shiny Server Pro*.

The underlying infrastructure of the simulation is provided by the
`simmer` package (for discrete event simulations). In other words,
`shimmer` simulates how Shiny apps scale by using the `simmer`
simulation framework.

## Installation

The package is not yet on CRAN…

<!--
You can install the released version of pkg from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("pkg")
```
-->

… but you can install the development version from
[GitHub](https://github.com/andrie/shimmer) using:

``` r
# install.packages("devtools")
devtools::install_github("andrie/shimmer")
```

## Example

The `shimmer` package uses discrete event simulation to help answer the
questions:

  - How big should my Shiny server be to handle `n` number of users?
  - For a given size of server, how many users can Shiny handle?
  - How should I tune the runtime parameters in RStudio Connect for my
    app?

The robust answer to this question is to use `shinyloadtest`, but for
planning purposes you may want to rapidly develop some hypotheses and
intuition about the problem, prior to building and testing an app.

## Relationship between `shimmer` and the `simmer` package

The `simmer` package makes it easy to build discrete event simulations
in R. The `shimmer` package uses `simmer` under the hood for defining
and running the simulation.

## Setting up the simulation

The `shimmer()` function reads a configuration file using the
`config::get()` function. The package contains a default configuration
file at:

``` r
system.file("config.yml", package = "shimmer")
#> [1] "C:/Users/apdev/Documents/R/win-library/3.4/shimmer/config.yml"
```

The contents of this file:

    default:
      runtime:
        comment: The app runtime settings that are available in RStudio Connect
        max_processes: 3
        min_processes: 0
        max_connections_per_process: 20
        load_factor: 0.5
        idle_timeout_per_process: 5.0
        initial_timeout: 300
        connection_timeout: 3600
        read_timeout: 3600
      app:
        comment: Describes the app startup time and response time per click
        startup_time: 5.0
        response_time: 2.0
      user:
        arrival:
          comment: Arrival time between users (seconds)
          mean: 10.0
          shape: 5.0
        number_of_requests_per_user: 20.0
        request:
          comment: Mean arrival time between requests for a given user (seconds)
          mean: 10.0
          shape: 5.0
        idle:
          comment: Time in seconds that connection remains live after last request
          mean: 1800
          sd: 600
      system:
        cpu: 4.0

## Run the simulation

``` r
library(magrittr)
library(shimmer)
```

By default, the simulation runs for an hour (3,600 seconds) of
simulation time:

``` r
env <- shimmer()
#> You must specify either config or a valid config_file.
#> Using the built-in config file.
env
#> simmer environment: Shiny | now: 3600 | next: 3600
#> { Monitor: in memory }
#> { Resource: connection_request | monitored: TRUE | server status: 60(60) | queue status: 0(0) }
#> { Resource: total_connections | monitored: TRUE | server status: 123(Inf) | queue status: 0(0) }
#> { Resource: rejections | monitored: TRUE | server status: 243(Inf) | queue status: 0(0) }
#> { Resource: connection | monitored: TRUE | server status: 60(60) | queue status: 0(Inf) }
#> { Resource: cpu | monitored: TRUE | server status: 1(4) | queue status: 0(Inf) }
#> { Resource: process_1 | monitored: TRUE | server status: 20(20) | queue status: 0(0) }
#> { Resource: request_queue_1 | monitored: TRUE | server status: 0(1) | queue status: 0(Inf) }
#> { Resource: process_2 | monitored: TRUE | server status: 20(20) | queue status: 0(0) }
#> { Resource: request_queue_2 | monitored: TRUE | server status: 1(1) | queue status: 1(Inf) }
#> { Resource: process_3 | monitored: TRUE | server status: 20(20) | queue status: 0(0) }
#> { Resource: request_queue_3 | monitored: TRUE | server status: 0(1) | queue status: 0(Inf) }
#> { Source: controller | monitored: 1 | n_generated: 1 }
#> { Source: user_accounting | monitored: 1 | n_generated: 367 }
```

## Plots

You can generate several plots from the simulation:

  - CPU usage
  - Response histogram
  - Rejected connections (because the system was too busy)

<!-- end list -->

``` r
env %>%
  plot_shimmer_cpu_usage()
```

![](man/figures/README-unnamed-chunk-6-1.png)<!-- -->

``` r
env %>%
  plot_shimmer_response_histogram()
```

![](man/figures/README-unnamed-chunk-7-1.png)<!-- -->

``` r
env %>%
  plot_shimmer_rejection_usage()
```

![](man/figures/README-unnamed-chunk-8-1.png)<!-- -->

In addition, you can also get more detail of the underlying system
behaviour:

  - Connections
  - Connections per process

<!-- end list -->

``` r
env %>%
  plot_shimmer_connection_usage()
```

![](man/figures/README-unnamed-chunk-9-1.png)<!-- -->

``` r
env %>%
  plot_shimmer_process_usage()
```

![](man/figures/README-unnamed-chunk-10-1.png)<!-- -->
