test_that("log_messages", {
  expect_snapshot({
    writeLines(eval_outside("log_messages()", "message(42)"))
  })
})

test_that("log_warnings", {
  expect_snapshot({
    writeLines(eval_outside("log_warnings(TRUE)", "warning(42)", "log(-1)"))
  })
})

test_that("log_errors", {
  expect_snapshot({
    writeLines(eval_outside("log_errors()", "stop(42)"))
    writeLines(eval_outside("log_errors()", "foobar"))
    writeLines(eval_outside("log_errors()", 'f<-function(x) {42 * "foobar"}; f()'))
    writeLines(eval_outside(
      "log_errors(traceback = TRUE)", 
      'source("helper.R", keep.source = TRUE)', 
      "function_that_fails()"))
  })
})

test_that("shiny input initialization is detected", {
  obs <- eval_outside("
    .globals <- shiny:::.globals
    .globals$appState <- new.env(parent = emptyenv())
    server <- function(input, output, session) {
        logger::log_shiny_input_changes(input)
    }
    shiny::testServer(server, {})
  ")
  expect_snapshot(writeLines(obs))
})

test_that("shiny input initialization is detected with different log-level", {
  obs <- eval_outside("
    .globals <- shiny:::.globals
    .globals$appState <- new.env(parent = emptyenv())
    server <- function(input, output, session) {
        logger::log_shiny_input_changes(input, level = logger::ERROR)
    }
    shiny::testServer(server, {})
  ")
  expect_snapshot(writeLines(obs))
})

test_that("shiny input change is detected", {
  obs <- eval_outside("
    .globals <- shiny:::.globals
    .globals$appState <- new.env(parent = emptyenv())
    server <- function(input, output, session) {
        logger::log_shiny_input_changes(input)
        x <- shiny::reactive(input$a)
    }
    shiny::testServer(server, {
        session$setInputs(a = 2)
    })
  ")
  expect_snapshot(writeLines(obs))
})

test_that("shiny input change is logged with different level", {
  obs <- eval_outside("
    .globals <- shiny:::.globals
    .globals$appState <- new.env(parent = emptyenv())
    server <- function(input, output, session) {
        logger::log_shiny_input_changes(input, level = logger::ERROR)
        x <- shiny::reactive(input$a)
    }
    shiny::testServer(server, {
        session$setInputs(a = 2)
    })
  ")
  expect_snapshot(writeLines(obs))
})
