library(logger)
library(testthat)

## save current settings so that we can reset later
layout   <- log_layout()
appender <- log_appender()

context('CRAN skip: logging from packages')

test_that('called from package', {
    devtools::load_all(system.file('demo-packages/logger-tester-package', package = 'logger'))
    local_test_logger(layout = layout_simple)
    expect_output(logger_tester_function(INFO, 'x = '), 'INFO')
    expect_output(logger_info_tester_function('everything = '), 'INFO')
})

test_that('namespace in a remote R session to avoid calling from testthat', {

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      log_info("foobar")', file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE),
        'global / global / R_GlobalEnv / NA / NA')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      f <- function() log_info("foobar")
      f()', file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE),
        'global / global / R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- function() f()
      g()', file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE),
        'global / global / R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- f
      g()', file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE),
        'global / global / R_GlobalEnv / g / g()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      log_appender(appender_stdout)
      devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"), quiet = TRUE)
      logger_info_tester_function("foobar")',
      file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t), intern = TRUE),
        'logger.tester / global / logger.tester / logger_info_tester_function / logger_info_tester_function("foobar")')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}"))
      devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"), quiet = TRUE)
      log_threshold(INFO, namespace = "logger.tester")
      log_appender(appender_stdout, namespace = "logger.tester")
      logger_info_tester_function("foobar")',
      file = t)
    expect_equal(
        system(paste('$R_HOME/bin/Rscript', t), intern = TRUE),
        'logger.tester / logger.tester / logger.tester / logger_info_tester_function / logger_info_tester_function("foobar")')
    unlink(t)

})

## reset settings
log_layout(layout)
log_appender(appender)
