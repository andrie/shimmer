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
    scale <- input$user_mean / shape


    dat <- data.frame(
      x = rgamma(1e4, shape = shape, scale = scale)
    )
    ggplot(dat, aes(x)) + geom_histogram(bins = 50) + coord_cartesian(xlim = user_defaults$user_mean)
  })

  output$request_plot <- renderPlot({
    shape <- input$request_shape
    scale <- input$request_mean / shape

    dat <- data.frame(
      x = rgamma(1e4, shape = shape, scale = scale)
    )
    ggplot(dat, aes(x)) + geom_histogram(bins = 50) + coord_cartesian(xlim = user_defaults$request_mean)
  })


  # Dashboard tab

  observeEvent(input$go_button, {
    # reactive({
    min_processes <- input$processes[1]
    max_processes <- input$processes[2]
    max_connections_per_process <- input$max_connections_per_process
    load_factor <- input$load_factor
    cpu <- input$cpu

    params <- params_default %>% modifyList(
      list(
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

    env <- shimmer(config = params)

    # })

    output$resource_plot <- renderPlot({
      env %>% plot_shimmer_resources()
    })
    output$usage_plot <- renderPlot({
      env %>% plot_shimmer_usage()
    })
    output$cpu_histogram <- renderPlot({
      env %>% plot_shimmer_cpu_histogram()
    })

  })


})
