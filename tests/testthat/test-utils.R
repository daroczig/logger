library(logger)
library(testthat)

## save current settings so that we can reset later
appender <- log_appender()
log_appender(appender_stdout)

context('utils')

test_that('fail_on_missing_package', {
    expect_error(fail_on_missing_package('logger'), NA)
    expect_error(fail_on_missing_package('an.R.package-that-doesNotExists'))
})

test_that('except helper', {
    expect_equal(Mean(1:10) %except% sum(1:10) / length(1:10), 5.5)
    expect_output(Mean(1:10) %except% sum(1:10) / length(1:10), 'WARN')
})

test_that('validate_log_level', {
    expect_equal(logger:::validate_log_level(ERROR), ERROR)
    expect_equal(logger:::validate_log_level('ERROR'), ERROR)
    expect_error(logger:::validate_log_level('FOOBAR'))
})

## reset settings
log_appender(appender)
