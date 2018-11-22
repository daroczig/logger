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
    ## log_layout(layout_glue_generator('{namespace} / {fn} / {call}'))
    ## f <- function() log_info('foobar')
    ## expect_equal(capture.output(f()), 'R_GlobalEnv / f / f()')
    ## g <- function() f()
    ## expect_equal(capture.output(g()), 'R_GlobalEnv / f / f()')
    ## g <- f
    ## expect_equal(capture.output(g()), 'R_GlobalEnv / g / g()')
})

test_that('print.level', {
    expect_equal(capture.output(print(INFO)), 'Log level: INFO')
})

## reset settings
log_threshold(threshold)
log_layout(layout)
