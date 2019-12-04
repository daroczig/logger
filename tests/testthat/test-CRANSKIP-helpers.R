library(logger)
library(testthat)

context('CRAN skip: helpers')

test_that('tictoc', {
    expect_match(capture.output(log_tictoc(), type = 'message'), 'timer tic 0 secs')
    ## let time pass a bit
    Sys.sleep(0.01)
    expect_match(capture.output(log_tictoc(), type = 'message'), 'timer toc')
    capture.output(expect_silent(log_tictoc()), type = 'message')
})

test_that('log with separator', {
    expect_output(
        cat(system("$R_HOME/bin/Rscript -e 'logger::log_with_separator(42)' 2>&1", intern = TRUE)),
        '===')
    expect_output(
        cat(system("$R_HOME/bin/Rscript -e 'logger::log_with_separator(42)' 2>&1", intern = TRUE)),
        '42')
    expect_output(
        cat(system("$R_HOME/bin/Rscript -e 'logger::log_with_separator(42, separator = \"|\")' 2>&1", intern = TRUE)),
        '|||||')
})
