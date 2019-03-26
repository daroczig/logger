library(logger)
library(testthat)

context('CRAN skip: helpers')

test_that('tictoc', {
    expect_output(log_tictoc(), 'timer tic 0 secs')
    expect_output(log_tictoc(), 'timer toc')
})

test_that('log with separator', {
    expect_error(log_with_separator(42), NA)
    expect_output(
        cat(system("Rscript -e 'logger::log_with_separator(42)'", intern = TRUE)),
        '===')
    expect_output(
        cat(system("Rscript -e 'logger::log_with_separator(42)'", intern = TRUE)),
        '42')
    expect_output(
        cat(system("Rscript -e 'logger::log_with_separator(42, separator = \"|\")'", intern = TRUE)),
        '|||||')
})
