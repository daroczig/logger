eval_outside <- function(...) {
  input <- normalizePath(withr::local_tempfile(lines = character()), winslash = "/")
  output <- normalizePath(withr::local_tempfile(lines = character()), winslash = "/")
  writeLines(con = input, c(
    "library(logger)",
    "log_layout(layout_glue_generator('{level} {msg}'))",
    paste0("log_appender(appender_file('", output, "'))"),
    ...
  ))
  path <- file.path(R.home("bin"), "Rscript")
  if (Sys.info()[["sysname"]] == "Windows") {
    path <- paste0(path, ".exe")
  }
  suppressWarnings(system2(path, input, stdout = TRUE, stderr = TRUE))
  readLines(output)
}

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
  })
})

test_that("shiny input initialization is detected", {
  obs <-
    eval_outside("
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
  obs <-
    eval_outside("
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
  obs <-
    eval_outside("
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
  obs <-
    eval_outside("
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
