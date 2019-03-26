library(logger)
library(testthat)

context('helpers')

test_that('separator', {
    expect_output(log_separator(), '===')
    expect_output(log_separator(separator = '-'), '---')
    expect_output(log_separator(), 'INFO')
    expect_output(log_separator(WARN), 'WARN')
})
