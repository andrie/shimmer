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
                  min = 5,
                  max = 50,
                  step = 5,
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
                  min = 4,
                  max = 32,
                  step = 4,
                  value = 8)
    ),
    # go button !!!
    box(width = 12, actionButton("go_button", "Go!")),

    # first row of output with value boxes

    conditionalPanel(
      "input.go_button >= 1",
      fluidRow(
        valueBoxOutput("cpu_box"),
        valueBoxOutput("rejection_box"),
        valueBoxOutput("duration_box")
      )
    ),

    # second row of output with key plots

    conditionalPanel(
      "input.go_button >= 1",
      fluidRow(
        class = "row300",
        box(
          width = 4,
          plotOutput("cpu_usage_plot", height = "200px") %>% withSpinner()
        ),
        box(
          width = 4,
          plotOutput("rejection_usage_plot", height = "200px") %>% withSpinner()
        ),
        box(
          width = 4,
          plotOutput("cpu_histogram", height = "200px") %>% withSpinner()
        )
      ),

      # third  row of output with detail plots

      fluidRow(
        class = "row300",
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
