library(logger)
library(testthat)

context('helpers')

test_that('separator', {
    expect_output(log_separator(), '===')
    expect_output(log_separator(separator = '-'), '---')
    expect_output(log_separator(), 'INFO')
    expect_output(log_separator(WARN), 'WARN')
})

test_that('tictoc', {
    expect_output(log_tictoc(), 'timer')
})

test_that('log with separator', {
    expect_output(log_with_separator(42), '===')
})

test_that('log failure', {
  expect_output(log_failure("foobar"), NA)
  expect_output(log_failure(foobar), 'ERROR.*foobar')
})
