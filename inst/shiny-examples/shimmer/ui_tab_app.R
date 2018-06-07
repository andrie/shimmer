

ui_tab_app <- tabItem(
  tabName = "app",
  fluidRow(
    box(
      title = "App startup and response time",
      width = 6,
      with(
        defaults$ui$app$app_startup_time,
        sliderInput("app_startup_time",
                    "App startup time:",
                    min = min,
                    max = max,
                    value = value
        )
      ),
      with(
        defaults$ui$app$app_response_time,
        sliderInput("app_response_time",
                    "App response time:",
                    min = min,
                    max = max,
                    value = value
        )
      )
    )
  )
)
