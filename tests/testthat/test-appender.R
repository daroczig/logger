library(logger)
library(testthat)

## save current settings so that we can reset later
threshold <- log_threshold()
layout    <- log_layout()
appender  <- log_appender()

context('appenders')

test_that('append to file', {
    log_layout(layout_glue_generator('{level} {msg}'))
    log_threshold(TRACE)
    t <- tempfile()
    log_appender(appender_file(t))
    log_info('foobar')
    log_info('{1:2}')
    expect_equal(length(readLines(t)), 3)
    expect_equal(readLines(t)[1], 'INFO foobar')
    unlink(t)
    rm(t)
})

test_that('append to file + print to console', {
    t <- tempfile()
    log_appender(appender_tee(t))
    expect_equal(capture.output(log_info('foobar')), 'INFO foobar')
    devnull <- capture.output(log_info('{1:2}'))
    expect_equal(length(readLines(t)), 3)
    expect_equal(readLines(t)[1], 'INFO foobar')
    unlink(t)
    rm(t)
})

## reset settings
log_threshold(threshold)
log_layout(layout)
log_appender(appender)
