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




sidebar <-   dashboardSidebar(
  sidebarMenu(
    menuItem("Users", tabName = "users", icon = icon("th")),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  )
)

source("ui_tab_users.R", local = TRUE)
source("ui_tab_dashboard.R", local = TRUE)


body <- dashboardBody(
  tabItems(
  ui_tab_dashboard,
  ui_tab_users
  )
)

dashboardPage(
  dashboardHeader(title = "Shimmer: Shiny sizing simulation"),
  sidebar,
  body
)



