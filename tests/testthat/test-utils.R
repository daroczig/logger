library(logger)
library(testthat)

context('utils')

test_that('fail_on_missing_package', {
    expect_error(fail_on_missing_package('logger'), NA)
    expect_error(fail_on_missing_package('an.R.package-that-doesNotExists'))
})
