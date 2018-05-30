

ui_tab_users <- tabItem(
  tabName = "users",
  fluidRow(
    box(
      title = "User arrival time",
      width = 6,
      sliderInput("user_mean",
                  "mean arrival time:",
                  min = user_defaults$user_mean[1],
                  max = user_defaults$user_mean[2],
                  value = c(30)
      ),
      sliderInput("user_shape",
                  "shape:",
                  min = 1,
                  max = 50,
                  value = 10
      )
    ),
    box(
      title = "Request arrival time",
      width = 6,
      sliderInput("request_mean",
                  "mean arrival time:",
                  min = user_defaults$request_mean[1],
                  max = user_defaults$request_mean[2],
                  value = c(10)
      ),
      sliderInput("request_shape",
                  "shape:",
                  min = 1,
                  max = 50,
                  value = 10
      ),
      sliderInput("request_number",
                  "number of requests:",
                  min = 0,
                  max = 50,
                  value = 10
      )
    )
  ),
  fluidRow(
    box(
      width = 6,
      plotOutput("user_plot")
    ),
    box(
      width = 6,
      plotOutput("request_plot")
    )
  )
)
