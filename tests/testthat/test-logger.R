library(logger)
library(testthat)

## save current settings so that we can reset later
threshold <- log_threshold()
layout <- log_layout()

context('loggers')

log_threshold(WARN)
test_that('log levels', {
    expect_output(log_fatal('foo'), 'FATAL.*foo')
    expect_output(log_error('foo'), 'ERROR.*foo')
    expect_output(log_warn('foo'), 'WARN.*foo')
    expect_output(log_success('foo'), NA)
    expect_output(log_info('foo'), NA)
    expect_output(log_debug('foo'), NA)
    expect_output(log_trace('foo'), NA)
})

log_threshold(TRACE)
test_that('log thresholds', {
    expect_output(log_fatal('foo'), 'FATAL.*foo')
    expect_output(log_error('foo'), 'ERROR.*foo')
    expect_output(log_warn('foo'), 'WARN.*foo')
    expect_output(log_success('foo'), 'SUCCESS.*foo')
    expect_output(log_info('foo'), 'INFO.*foo')
    expect_output(log_debug('foo'), 'DEBUG.*foo')
    expect_output(log_trace('foo'), 'TRACE.*foo')
})

log_threshold(WARN)
test_that('with log thresholds', {
    expect_output(with_log_threshold(log_fatal('foo'), threshold = TRACE), 'FATAL.*foo')
    expect_output(with_log_threshold(log_error('foo'), threshold = TRACE), 'ERROR.*foo')
    expect_output(with_log_threshold(log_error('foo'), threshold = FATAL), NA)
    expect_output(with_log_threshold(log_error('foo'), threshold = INFO), 'ERROR.*foo')
    expect_output(with_log_threshold(log_debug('foo'), threshold = INFO), NA)
})

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

test_that('built in variables: pid', {
    log_layout(layout_glue_generator('{pid}'))
    expect_equal(capture.output(log_info('foobar')), as.character(Sys.getpid()))
})

test_that('built in variables: fn and call', {
    log_layout(layout_glue_generator('{fn} / {call}'))
    f <- function() log_info('foobar')
    expect_output(f(), 'f / f()')
    g <- function() f()
    expect_output(g(), 'f / f()')
    g <- f
    expect_output(g(), 'g / g()')
})

test_that('built in variables: namespace', {
    log_layout(layout_glue_generator('{ns}'))
    expect_output(log_info('bar', namespace = 'foo'), 'foo')
    log_layout(layout_glue_generator('{ans}'))
    expect_output(log_info('bar', namespace = 'foo'), 'global')
})

test_that('print.level', {
    expect_equal(capture.output(print(INFO)), 'Log level: INFO')
})

## reset settings
log_threshold(threshold)
log_layout(layout)
