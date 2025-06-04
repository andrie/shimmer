#' Defines the location of the example config.yml
#'
#' @export
#' @seealso [shimmer()]
shimmer_config_file <- function() {
  system.file("config.yml", package = "shimmer")
}

#' Defines shiny simulation and runs for a specified period of time.
#'
#' This uses the `simmer` package to set up a simulation run.
#'
#'
#' @param until Time in seconds
#' @param config Configuration parameters. If not provided, then attempts to read from the `config_file`
#' @param config_file Path to config file with runtime and app settings.  If neither `config` nor `config_file` is provided, attempts to read from [shimmer_config_file()].
#'
#' @return a `simmer` environment
#' @export
#'
#' @seealso [shimmer_config_file()]
#'
shimmer <- function(until = 3600, config, config_file) {
  if (missing(config) && missing(config_file)) {
    message(
      "You must specify either config or a valid config_file.\n",
      "Using the built-in config file."
    )
    config_file <- shimmer_config_file()
    assert_that(file.exists(config_file))
    params <- config::get(file = config_file)
  }

  if (missing(config)) {
    config_file <- shimmer_config_file()
    assert_that(file.exists(config_file))
    params <- config::get(file = config_file)
  } else {
    params <- config
  }

  select <- simmer::select

  env <- simmer("Shiny")
  RUNTIME <- params[["runtime"]]
  USER <- params[["user"]]
  SYSTEM <- params[["system"]]
  APP <- params[["app"]]

  total_allowed_connections <- with(
    RUNTIME,
    max_processes * max_connections_per_process
  )

  ACTIVE_CONNECTIONS <- 0
  TOTAL_CONNECTIONS <- 0
  ACTIVE_PROCESSES <- 0

  rectified_rnorm <- function(n = 1, mean = 0, sd = 1) {
    max(0, stats::rnorm(n, mean, sd))
  }

  get_active_process_names <- function() {
    if (ACTIVE_PROCESSES == 0) {
      character(0)
    } else {
      paste0("process_", seq_len(ACTIVE_PROCESSES))
    }
  }

  # CPU trajectory ----------------------------------------------------------

  cput <- trajectory("cpu") %>%
    seize("cpu") %>%
    timeout(APP$response_time) %>%
    release("cpu")

  request <- trajectory("request") %>%
    select(
      function()
        paste0("request_queue_", simmer::get_attribute(env, keys = "process")),
      id = 2
    ) %>%
    seize_selected(id = 2) %>%
    join(cput) %>%
    release_selected(id = 2)

  # Controller ------------------------------------------------------------

  # The controller periodally checks active connections and starts up new
  # processes if required

  add_process <- function(.env) {
    i <- ACTIVE_PROCESSES + 1

    trajectory() %>%
      seize("cpu") %>%
      timeout(APP$startup_time) %>%
      release("cpu") %>%
      set_capacity(
        "connection",
        function() i * RUNTIME$max_connections_per_process
      )
    updated_env <- env %>%
      add_resource(
        paste0("process_", i),
        capacity = RUNTIME$max_connections_per_process,
        queue_size = 0
      ) %>%
      add_resource(
        paste0("request_queue_", i),
        capacity = 1,
        queue_size = Inf
      )

    ACTIVE_PROCESSES <<- i
    updated_env
  }

  controller <- trajectory("controller", verbose = TRUE) %>%
    branch(
      function() {
        new_processes <- max(1, RUNTIME$min_processes - ACTIVE_PROCESSES)
        for (i in seq_len(new_processes)) {
          env %>% add_process()
        }
        0
      },
      continue = TRUE
    ) %>%
    branch(
      function() {
        load_factor <- local({
          active <- ACTIVE_CONNECTIONS
          allowed <- ACTIVE_PROCESSES * RUNTIME$max_connections_per_process
          if (active == 0) 0 else active / allowed
        })
        if (
          load_factor > RUNTIME$load_factor &&
            ACTIVE_PROCESSES < RUNTIME$max_processes
        ) {
          env %>% add_process()
        }
        0
      },
      continue = TRUE
    ) %>%
    timeout(1) %>%
    rollback(2, Inf)

  # Define the user trajectory --------------------------------------------

  # - seize a connection
  # - select and seize a process (based on a defined selection policy)
  # - seize a CPU
  # - time out for the duration of the app response time
  # - release the CPU
  # - wait for the request inter-arrival time, then rinse and repeat
  # - once the user's last request comes in, wait to simulate an idle user

  inc_active_connections <- function() {
    ACTIVE_CONNECTIONS <<- ACTIVE_CONNECTIONS + 1
    TOTAL_CONNECTIONS <<- TOTAL_CONNECTIONS + 1
    return(1)
  }

  dec_active_connections <- function() {
    ACTIVE_CONNECTIONS <<- ACTIVE_CONNECTIONS - 1
    return(1)
  }

  timeout_until_idle <- function(.trj) {
    .trj %>%
      timeout(function() {
        user_timeout <- agamma(mean = 1800, shape = 10)
        min(user_timeout, SYSTEM$connection_timeout)
      })
  }

  shortest_queue <- function() {
    active <- simmer::get_mon_resources(env) %>%
      dplyr::filter(grepl("process_", resource)) %>%
      dplyr::mutate(queue = server + queue) %>%
      dplyr::select(resource, queue) %>%
      dplyr::group_by(resource) %>%
      dplyr::slice(dplyr::n()) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(queue) %>%
      .[["resource"]]

    all <- get_active_process_names()
    inactive <- setdiff(all, active)

    if (length(all) == 0) return(1)

    r <- ifelse(length(inactive) >= 1, inactive[1], active[1])

    if (length(r) == 0) return(1)

    z <- as.numeric(gsub("process_", "", r))
    if (is.na(z)) 1 else z
  }

  user <- trajectory("user") %>%
    seize("connection") %>%

    # select process
    select(
      function()
        paste0("process_", simmer::get_attribute(env, keys = "process"))
    ) %>%
    seize_selected() %>%
    join(request) %>%

    # time out waiting for next request
    timeout(
      function() agamma(mean = USER$request$mean, shape = USER$request$shape)
    ) %>%
    rollback(
      get_n_activities(request) + 1,
      times = USER$number_of_requests_per_user - 1
    ) %>%

    # time out for idle connection
    timeout_until_idle() %>%
    release_selected() %>%

    release("connection")

  # The user accounting trajectory is a wrapper around the user trajectory. It
  # exists to count the total number of connections and rejections.

  user_accounting <- trajectory("accounting") %>%
    simmer::set_attribute(
      keys = "process",
      values = function() shortest_queue()
    ) %>%
    seize(
      "connection_request",
      amount = inc_active_connections,
      continue = FALSE,
      reject = trajectory() %>%
        seize("rejections")
    ) %>%
    seize("total_connections") %>%
    join(user) %>%
    release("connection_request", amount = dec_active_connections)

  ## Run the simulation ---------------------------------------------------

  run_without_warn <- function(.env, until = Inf, progress = NULL, steps = 10) {
    suppressWarnings(
      simmer::run(.env, until = until, progress = progress, steps = steps)
    )
  }

  env %>%
    add_resource(
      "connection_request",
      capacity = total_allowed_connections,
      queue_size = 0
    ) %>%
    add_resource("total_connections", capacity = Inf, queue_size = 0) %>%
    add_resource("rejections", capacity = Inf, queue_size = 0) %>%
    add_resource(
      "connection",
      capacity = total_allowed_connections,
      queue_size = Inf
    ) %>%
    add_resource("cpu", capacity = SYSTEM$cpu, queue_size = Inf) %>%
    add_generator("controller", controller, at(0)) %>%
    add_generator(
      "user_accounting",
      user_accounting,
      mon = 1,
      distribution = function() {
        agamma(1, shape = USER$arrival$shape, mean = USER$arrival$mean)
      }
    ) %>%
    run_without_warn(until)
}
