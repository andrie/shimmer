# Defines the dashboard tab

ui_tab_dashboard <- tabItem(
  tabName = "dashboard",
  fluidRow(
    box(
      width = 3,
      sliderInput("processes",
                  "min and max processes:",
                  min = 0,
                  max = 20,
                  value = c(0, 3))
    ),
    box(
      width = 3,
      sliderInput("max_connections_per_process",
                  "max connections per process:",
                  min = 1,
                  max = 50,
                  value = 20)
    ),
    box(
      width = 3,
      sliderInput("load_factor",
                  "load factor:",
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
    box(width = 12, actionButton("go_button", "Go!")),
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
