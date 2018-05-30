#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggplot2)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {


  params_default <- shimmer_config_file() %>%
    yaml::read_yaml() %>%
    .$default

  # User tab

  output$user_plot <- renderPlot({
    # a = shape
    # s = scale
    # m = a*s  thus  s = m/a
    # var = a*s^2  thus s = sqrt(var / a)

    shape <- input$user_shape
    mean <- input$user_mean

    dat <- data.frame(x = agamma(1e4, shape = shape, mean = mean))
    ggplot(dat, aes(x)) +
      geom_histogram(binwidth = 1) +
      coord_cartesian(xlim = user_defaults$user_mean)
  })

  output$request_plot <- renderPlot({
    shape <- input$request_shape
    mean <- input$request_mean

    dat <- data.frame(x = agamma(1e4, shape = shape, mean = mean))
    ggplot(dat, aes(x)) +
      geom_histogram(binwidth = 1) +
      coord_cartesian(xlim = user_defaults$request_mean)
  })

  params <- reactive({

    min_processes <- input$processes[1]
    max_processes <- input$processes[2]
    max_connections_per_process <- input$max_connections_per_process
    load_factor <- input$load_factor

    cpu <- input$cpu

    params_default %>% modifyList(
      list(
        user = list(
          arrival = list(
            mean = input$user_mean,
            shape = input$user_shape
          ),
          request = list(
            mean = input$request_mean,
            shape = input$request_shape
          ),
          number_of_requests = input$request_number

        ),
        system = list(
          cpu = cpu
        ),
        runtime = list(
          min_processes  = min_processes,
          max_processes = max_processes,
          max_connections_per_process = max_connections_per_process,
          load_factor = load_factor
        ))
    )
  })



  # Dashboard tab

  observeEvent(input$go_button, {

    env <- shimmer(config = params())

    output$connection_usage_plot <- renderPlot({
      env %>% plot_shimmer_connection_usage()
    })
    output$rejection_usage_plot <- renderPlot({
      env %>% plot_shimmer_rejection_usage()
    })
    output$cpu_histogram <- renderPlot({
      env %>% plot_shimmer_response_histogram()
    })

    output$cpu_usage_plot <- renderPlot({
      env %>% plot_shimmer_cpu_usage()
    })
    output$process_usage_plot <- renderPlot({
      env %>% plot_shimmer_process_usage()
    })

  })


})
