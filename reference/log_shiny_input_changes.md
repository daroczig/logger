# Auto logging input changes in Shiny app

This is to be called in the `server` section of the Shiny app.

## Usage

``` r
log_shiny_input_changes(
  input,
  level = INFO,
  namespace = NA_character_,
  excluded_inputs = character()
)
```

## Arguments

- input:

  passed from Shiny's `server`

- level:

  log level

- namespace:

  the name of the namespace

- excluded_inputs:

  character vector of input names to exclude from logging

## Examples

``` r
if (FALSE) { # \dontrun{
library(shiny)

ui <- bootstrapPage(
  numericInput("mean", "mean", 0),
  numericInput("sd", "sd", 1),
  textInput("title", "title", "title"),
  textInput("foo", "This is not used at all, still gets logged", "foo"),
  passwordInput("password", "Password not to be logged", "secret"),
  plotOutput("plot")
)

server <- function(input, output) {
  logger::log_shiny_input_changes(input, excluded_inputs = "password")

  output$plot <- renderPlot({
    hist(rnorm(1e3, input$mean, input$sd), main = input$title)
  })
}

shinyApp(ui = ui, server = server)
} # }
```
