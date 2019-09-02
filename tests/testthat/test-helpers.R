library(logger)
library(testthat)

## save current settings so that we can reset later
appender <- log_appender()

log_appender(appender_stdout)

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
  expect_output(try(log_failure(foobar), silent = TRUE), 'ERROR.*foobar')
  expect_error(log_failure('foobar'), NA)
  expect_error(log_failure(foobar))
})

## reset settings
log_appender(appender)
