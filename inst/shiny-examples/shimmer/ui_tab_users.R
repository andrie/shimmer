

ui_tab_users <- tabItem(
  tabName = "users",
  fluidRow(
    box(
      title = "Arrival of users",
      width = 6,
      with(
        defaults$ui$users$user_mean,
        sliderInput("user_mean",
                    "mean arrival time:",
                    min = min,
                    max = max,
                    value = value,
                    step = step
        )
      ),
      with(
        defaults$ui$users$user_shape,
        sliderInput("user_shape",
                    "shape:",
                    min = min,
                    max = max,
                    value = value,
                    step = step
        )
      )
    ),
    box(
      title = "Requests made by each user",
      width = 6,
      with(
        defaults$ui$users$request_mean,
        sliderInput("request_mean",
                    "mean arrival time:",
                    min = min,
                    max = max,
                    value = value,
                    step = step
        )
      ),
      with(
        defaults$ui$users$request_shape,
        sliderInput("request_shape",
                    "shape:",
                    min = min,
                    max = max,
                    value = value,
                    step = step
        )
      ),
      with(
        defaults$ui$users$request_number,
        sliderInput("request_number",
                    "number of requests:",
                    min = min,
                    max = max,
                    value = value,
                    step = step
        )
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
