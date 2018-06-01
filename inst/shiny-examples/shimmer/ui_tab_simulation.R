# Defines the dashboard tab

ui_tab_simulation <- tabItem(
  tabName = "simulation",
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
    # go button !!!
    box(width = 12, actionButton("go_button", "Go!")),

    # first row of output

    conditionalPanel(
      "input.go_button >= 1",
      fluidRow(
        valueBoxOutput("rejection_box")
      )
    ),

    conditionalPanel(
      "input.go_button >= 1",
      fluidRow(
        box(
          width = 4,
          plotOutput("cpu_usage_plot") %>% withSpinner()
        ),
        box(
          width = 4,
          plotOutput("rejection_usage_plot") %>% withSpinner()
        ),
        box(
          width = 4,
          plotOutput("cpu_histogram") %>% withSpinner()
        )
      ),

      # second row of output
      fluidRow(
        box(
          width = 4,
          plotOutput("connection_usage_plot") %>% withSpinner()
        ),
        box(
          width = 8,
          plotOutput("process_usage_plot") %>% withSpinner()
        )
      )
    )

  )
)
