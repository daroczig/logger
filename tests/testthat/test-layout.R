library(logger)
library(testthat)
library(jsonlite)

## save current settings so that we can reset later
layout <- log_layout()

log_layout(layout_glue_colors)
test_that('colorized layout', {
    expect_output(log_info('foobar'), 'INFO')
    expect_output(log_info('foobar'), 'foobar')
    expect_output(log_error('foobar'), 'ERROR')
    expect_output(log_error('foobar'), 'foobar')
})

context('JSON layout')
log_layout(layout_json)
test_that('JSON layout', {
    expect_equal(fromJSON(capture.output(log_info('foobar')))$level, 'INFO')
    expect_equal(fromJSON(capture.output(log_info('foobar')))$message, 'foobar')
})

context('safe-checks')
test_that('mist throw errors', {

    expect_error(layout_simple(FOOBAR))
    expect_error(layout_simple(42))
    expect_error(layout_simple(msg = 'foobar'))

    expect_error(layout_glue(FOOBAR))
    expect_error(layout_glue(42))
    expect_error(layout_glue(msg = 'foobar'))
    expect_error(layout_glue(level = 53, msg = 'foobar'))

})


## reset settings
log_layout(layout)
