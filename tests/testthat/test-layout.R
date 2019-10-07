library(logger)
library(testthat)
library(jsonlite)

## save current settings so that we can reset later
layout <- log_layout()
appender <- log_appender()

context('layouts')

log_layout(layout_glue_colors)
log_appender(appender_stdout)

test_that('colorized layout', {
    expect_output(log_info('foobar'), 'INFO')
    expect_output(log_info('foobar'), 'foobar')
    expect_output(log_error('foobar'), 'ERROR')
    expect_output(log_error('foobar'), 'foobar')
})

log_layout(layout_json())
test_that('JSON layout', {
    expect_equal(fromJSON(capture.output(log_info('foobar')))$level, 'INFO')
    expect_equal(fromJSON(capture.output(log_info('foobar')))$msg, 'foobar')
})

log_layout(layout_json_parser(fields = c()))
test_that('JSON parser layout', {
    expect_output(log_info(skip_formatter('{"x": 4}')), '\\{"x":4\\}')
    expect_equal(capture.output(log_info(skip_formatter('{"x": 4}'))), '{"x":4}')
})

test_that('must throw errors', {

    expect_error(layout_simple(FOOBAR))
    expect_error(layout_simple(42))
    expect_error(layout_simple(msg = 'foobar'))

    expect_error(layout_glue(FOOBAR))
    expect_error(layout_glue(42))
    expect_error(layout_glue(msg = 'foobar'))
    expect_error(layout_glue(level = 53, msg = 'foobar'))

})

log_layout(layout_logging)
test_that('logging layout', {
    expect_output(log_info('foobar'), 'INFO')
    expect_output(log_info('foo', namespace = 'bar'), 'foo')
    expect_output(log_info('foo', namespace = 'bar'), 'bar')
    expect_output(log_info('foo', namespace = 'bar'), 'INFO:bar:foo')
})

## reset settings
log_layout(layout)
log_appender(appender)
