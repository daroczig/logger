library(logger)
library(testthat)

eval_outside <- function(expr) {
    t <- tempfile()
    on.exit(unlink(t))
    cat('library(logger); log_messages(); log_warnings(); log_errors();', file = t)
    cat(expr, file = t, append = TRUE, sep = '\n')
    paste(
        suppressWarnings(system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE)),
        collapse = '\n')
}

test_that('log_messages', {
    skip_on_os("windows")

    expect_match(eval_outside('message(42)'), 'INFO')
    expect_match(eval_outside('system("echo 42", invisible = TRUE)'), 'INFO')
})

test_that('log_warnings', {
    skip_on_os("windows")
    skip_if_not(getRversion() >= "4.0.0")

    expect_match(eval_outside('warning(42)'), 'WARN')
    expect_match(eval_outside('log(-1)'), 'WARN')
})

test_that('log_errors', {
    skip_on_os("windows")
    skip_if_not(getRversion() >= "4.0.0")

    expect_match(eval_outside('stop(42)'), 'ERROR')
    expect_match(eval_outside('foobar'), 'ERROR')
    expect_match(eval_outside('f<-function(x) {42 * "foobar"}; f()'), 'ERROR')
})

test_that('shiny input initialization is detected', {
    skip_on_os("windows")

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
    exp <- "INFO \\[[0-9: \\-]+\\] Default Shiny inputs initialized"
    expect_match(obs, exp)
})

test_that('shiny input initialization is detected with different log-level', {
    skip_on_os("windows")
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
    exp <- "ERROR \\[[0-9: \\-]+\\] Default Shiny inputs initialized"
    expect_match(obs, exp)
})

test_that('shiny input change is detected', {
    skip_on_os("windows")
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
    exp <- "INFO \\[[0-9: \\-]+\\] Shiny input change detected on a: NULL -> 2"
    expect_match(obs, exp)
})

test_that('shiny input change is logged with different level', {
    skip_on_os("windows")
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
    exp <- "ERROR \\[[0-9: \\-]+\\] Shiny input change detected on a: NULL -> 2"
    expect_match(obs, exp)
})
