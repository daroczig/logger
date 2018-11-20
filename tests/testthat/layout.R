library(logger)
library(testthat)
library(jsonlite)

## save current settings so that we can reset later
layout <- log_layout()
log_layout(layout_json)

context('JSON layout')
test_that('JSON layout', {
    expect_equal(fromJSON(capture.output(log_info('foobar')))$level, 'INFO')
    expect_equal(fromJSON(capture.output(log_info('foobar')))$message, 'foobar')
})

## reset settings
log_layout(layout)
