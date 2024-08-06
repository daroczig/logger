library(logger)
library(testthat)

eval_outside <- function(expr) {
    input <- normalizePath(withr::local_tempfile(lines = character()))
    output <- normalizePath(withr::local_tempfile(lines = character()))
    writeLines(con = input, c(
        "library(logger)",
        "log_layout(layout_glue_generator('{level} {msg}'))",
        paste0("log_appender(appender_file('", output, "'))"),
        "log_messages()",
        "log_warnings(TRUE)",
        "log_errors()",
        expr
    ))

    path <- file.path(R.home("bin"), "Rscript")
    if (Sys.info()[["sysname"]] == "Windows") {
        path <- paste0(path, ".exe")
    }
    # suppressWarnings(system2(path, input, stdout = TRUE, stderr = TRUE))
    suppressWarnings(system2(path, input))
    readLines(output)
}

test_that('log_messages', {
    skip_if_not(getRversion() >= "4.0.0")

    expect_snapshot({
        writeLines(eval_outside('message(42)'))
    })
})

test_that('log_warnings', {
    skip_if_not(getRversion() >= "4.0.0")

    expect_snapshot({
        writeLines(eval_outside('warning(42)'))
        writeLines(eval_outside('log(-1)'))
    })
})

test_that('log_errors', {
    skip_if_not(getRversion() >= "4.0.0")

    expect_snapshot({  
        writeLines(eval_outside('stop(42)'))
        writeLines(eval_outside('foobar'))
        writeLines(eval_outside('f<-function(x) {42 * "foobar"}; f()'))
    })
})

test_that('shiny input initialization is detected', {
    obs <-
        eval_outside("
            .globals <- shiny:::.globals
            .globals$appState <- new.env(parent = emptyenv())
            server <- function(input, output, session) {
                logger::log_shiny_input_changes(input)
            }
            shiny::testServer(server, {})
            "
        )
    expect_snapshot(writeLines(obs))
})

test_that('shiny input initialization is detected with different log-level', {
    obs <-
        eval_outside("
            .globals <- shiny:::.globals
            .globals$appState <- new.env(parent = emptyenv())
            server <- function(input, output, session) {
                logger::log_shiny_input_changes(input, level = logger::ERROR)
            }
            shiny::testServer(server, {})
            "
        )
    expect_snapshot(writeLines(obs))
})

test_that('shiny input change is detected', {
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
            "
        )
    expect_snapshot(writeLines(obs))
})

test_that('shiny input change is logged with different level', {
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
            "
        )
    expect_snapshot(writeLines(obs))
})
