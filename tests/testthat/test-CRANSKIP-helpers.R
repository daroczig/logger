library(logger)
library(testthat)

context('cranskip helpers')

test_that('tictoc', {
    expect_output(log_tictoc(), 'timer tic 0 secs')
    expect_output(log_tictoc(), 'timer toc')
})
