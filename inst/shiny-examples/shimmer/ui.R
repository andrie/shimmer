#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# max_processes: 3
# min_processes: 0
# max_connections_per_process: 20
# load_factor: 0.5
# idle_timeout_per_process: 5.0
# initial_timeout: 300
# connection_timeout: 3600
# read_timeout: 3600


library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram

dashboardPage(
  dashboardHeader(title = "Shimmer: Shiny sizing simulation"),
  dashboardSidebar(),
  dashboardBody(
    tabItem(
      tabName = "dashboard",
      fluidRow(
        box(
          width = 3,
          sliderInput("processes",
                      "min_processes and max_processes:",
                      min = 0,
                      max = 20,
                      value = c(0, 3))
        ),
        box(
          width = 3,
          sliderInput("max_connections_per_process",
                      "max_connections_per_process:",
                      min = 1,
                      max = 50,
                      value = 20)
        ),
        box(
          width = 3,
          sliderInput("load_factor",
                      "load_factor:",
                      min = 0,
                      max = 1,
                      value = 0.5,
                      step = 0.1)
        ),
        box(
          width = 3,
          sliderInput("cpu",
                      "cpu count:",
                      min = 1,
                      max = 8,
                      value = 4)
        ),
        fluidRow(
          box(
            width = 4,
            plotOutput("resource_plot")
          ),
          box(
            width = 4,
            plotOutput("usage_plot")
          ),
          box(
            width = 4,
            plotOutput("cpu_histogram")
          )
        )
      )
    )
  )
)



