library(logger)
library(testthat)

## save current settings so that we can reset later
threshold <- log_threshold()
layout <- log_layout()

context('loggers')

log_layout(layout_glue_generator('{level} {msg}'))
log_threshold(TRACE)
test_that('simple glue layout with no threshold', {
    expect_equal(capture.output(log_fatal('foobar')), 'FATAL foobar')
    expect_equal(capture.output(log_error('foobar')), 'ERROR foobar')
    expect_equal(capture.output(log_warn('foobar')), 'WARN foobar')
    expect_equal(capture.output(log_info('foobar')), 'INFO foobar')
    expect_equal(capture.output(log_debug('foobar')), 'DEBUG foobar')
    expect_equal(capture.output(log_trace('foobar')), 'TRACE foobar')
})

log_threshold(INFO)
test_that('simple glue layout with threshold', {
    expect_equal(capture.output(log_fatal('foobar')), 'FATAL foobar')
    expect_equal(capture.output(log_error('foobar')), 'ERROR foobar')
    expect_equal(capture.output(log_warn('foobar')), 'WARN foobar')
    expect_equal(capture.output(log_info('foobar')), 'INFO foobar')
    expect_equal(capture.output(log_debug('foobar')), character())
    expect_equal(capture.output(log_trace('foobar')), character())
})

test_that('simple glue layout with threshold directly calling log', {
    expect_equal(capture.output(log_level(FATAL, 'foobar')), 'FATAL foobar')
    expect_equal(capture.output(log_level(ERROR, 'foobar')), 'ERROR foobar')
    expect_equal(capture.output(log_level(WARN, 'foobar')), 'WARN foobar')
    expect_equal(capture.output(log_level(INFO, 'foobar')), 'INFO foobar')
    expect_equal(capture.output(log_level(DEBUG, 'foobar')), character())
    expect_equal(capture.output(log_level(TRACE, 'foobar')), character())
})

test_that('built in variables', {
    log_layout(layout_glue_generator('{pid}'))
    expect_equal(capture.output(log_info('foobar')), as.character(Sys.getpid()))
})

test_that('fn and call', {
    log_layout(layout_glue_generator('{fn} / {call}'))
    f <- function() log_info('foobar')
    expect_output(f(), 'f / f()')
    g <- function() f()
    expect_output(g(), 'f / f()')
    g <- f
    expect_output(g(), 'g / g()')
})

## setting R_TESTS to empty string because of https://github.com/hadley/testthat/issues/144
Sys.unsetenv('R_TESTS')

test_that('namespace in a remote R session to avoid calling from testthat', {

    ## R CMD check doesn't like the below "system" calls :/
    skip_on_cran()

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      log_info("foobar")', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / NA / NA')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      f()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- function() f()
      g()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- f
      g()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / g / g()')
    unlink(t)

})

test_that('called from package', {
    devtools::load_all(system.file('demo-packages/logger-tester-package', package = 'logger'))
    log_layout(layout_simple)
    expect_output(logger_tester_function(INFO, 'x = '), 'INFO')
    expect_output(logger_info_tester_function('everything = '), 'INFO')
})

test_that('print.level', {
    expect_equal(capture.output(print(INFO)), 'Log level: INFO')
})

## reset settings
log_threshold(threshold)
log_layout(layout)
