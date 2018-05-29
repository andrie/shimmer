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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


  params_default <- shimmer_config_file() %>%
    yaml::read_yaml() %>%
    .$default

  env <- reactive({
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

    shimmer(config = params)

  })

  output$resource_plot <- renderPlot({
    env() %>% plot_shiny_resources()
  })
  output$usage_plot <- renderPlot({
    env() %>% plot_shiny_usage()
  })
  output$cpu_histogram <- renderPlot({
    env() %>% plot_shiny_cpu_histogram()
  })

})
