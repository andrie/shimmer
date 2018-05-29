#' Defines shiny simulation and runs for a specified period of time
#'
#' @param until Time in seconds
#' @param config_file Path to config file with runtime and app settings
#'
#' @return a `simmer` environment
#' @export
#'
simmer_shiny <- function(
  until = 3600,
  config_file = system.file("config.yml", package = "simmer.shiny")
){

  assert_that(file.exists(config_file))

  select <- simmer::select

  params <- config::get(file = config_file)


  env <- simmer("Shiny")
  RUNTIME <- params[["runtime"]]
  USER <- params[["user"]]
  SYSTEM <- params[["system"]]
  APP <- params[["app"]]

  total_allowed_connections <- with(
    RUNTIME,
    max_processes * max_connections_per_process
  )


  ACTIVE_CONNECTIONS <-  0
  ACTIVE_PROCESSES <-  0

  rectified_rnorm <- function(n, mean = 0, sd = 1){
    max(0, rnorm(n, mean, sd))
  }


  get_active_process_names <- function(){
    if (ACTIVE_PROCESSES == 0) {
      character(0)
    } else {
      paste0("process_", seq_len(ACTIVE_PROCESSES))
    }
  }


  # CPU trajectory ----------------------------------------------------------

  cpu <- trajectory("cpu") %>%
    seize("cpu") %>%
    timeout(params$app$reponse_time) %>%
    release("cpu")


    # Controller ------------------------------------------------------------

  # The controller periodally checks active connections and starts up new
  # processes if required

  add_process <- function(.env){
    i <- ACTIVE_PROCESSES + 1

    updated_env <- env %>%
      add_resource(
        paste0("process_", i),
        capacity = RUNTIME$max_connections_per_process,
        queue_size = 0
      )

    trajectory() %>%
      set_capacity("connection",
                   function()i * RUNTIME$max_connections_per_process)
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
          allowed <-  ACTIVE_PROCESSES * RUNTIME$max_connections_per_process
          if (active == 0) 0 else active / allowed
        })
        if (load_factor > RUNTIME$load_factor &&
            ACTIVE_PROCESSES < RUNTIME$max_processes) {
          env %>% add_process()
        }
        0
      },
      continue = TRUE
    ) %>%
    timeout(10) %>%
    rollback(2, Inf)


  # Define the user trajectory --------------------------------------------

  # - seize a connection
  # - select and seize a process (based on a defined selection policy)
  # - seize a CPU
  # - time out for

  inc_active_connections <- function(){
    ACTIVE_CONNECTIONS <<- ACTIVE_CONNECTIONS + 1
    return(1)
  }

  dec_active_connections <- function(){
    ACTIVE_CONNECTIONS <<- ACTIVE_CONNECTIONS - 1
    return(1)
  }


  user <- trajectory("users") %>%
    seize("connection_request",
          amount = inc_active_connections,
          continue = FALSE,
          reject = trajectory() %>%
            seize("rejections") %>%
            timeout(until) %>%
            release("rejections")
    ) %>%
    seize("connection") %>%

    # select process
    select(resources = function()get_active_process_names(),
           policy = "shortest-queue") %>%
    seize_selected() %>%
    join(cpu) %>%

    # time out for response
    timeout(function() APP$reponse_time) %>%
    rollback(
      get_n_activities(cpu) + 1,
      times = USER$number_of_requests - 1
    ) %>%

    # time out for idle connection
    timeout(function() rectified_rnorm(1, mean = 600, sd = 30)) %>%
    release_selected() %>%

    release("connection",
            amount = dec_active_connections) %>%
    release("connection_request")


  ## Run the simulation ---------------------------------------------------

  env %>%
    add_resource("connection_request",
                 capacity = total_allowed_connections,
                 queue_size = 0) %>%
    add_resource("rejections",
                 capacity = Inf,
                 queue_size = 0) %>%
    add_resource("connection",
                 capacity = total_allowed_connections,
                 queue_size = Inf) %>%
    add_resource("cpu",
                 capacity = SYSTEM$cpu,
                 queue_size = Inf) %>%
    add_generator("controller",
                  controller, at(0)) %>%
    add_generator("user", user,
                  distribution = function() {
                    rectified_rnorm(1,
                                    mean = USER$arrival$mean,
                                    sd = USER$arrival$sd
                    )
                  }
    ) %>%
    run(until)
}


