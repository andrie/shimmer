

ui_tab_app <- tabItem(
  tabName = "app",
  fluidRow(
    box(
      title = "App startup and response time",
      width = 6,
      sliderInput("app_startup_time",
                  "App startup time:",
                  min = 0,
                  max = 60,
                  value = 5
      ),
      sliderInput("app_response_time",
                  "App response time:",
                  min = 0,
                  max = 60,
                  value = 2
      )
    )
  )
)
