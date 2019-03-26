library(logger)
library(testthat)

context('CRAN skip: helpers')

test_that('tictoc', {
    expect_output(log_tictoc(), 'timer tic 0 secs')
    expect_output(log_tictoc(), 'timer toc')
})
