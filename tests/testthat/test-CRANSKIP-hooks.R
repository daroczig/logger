library(logger)
library(testthat)

context('hooks')

eval_outside <- function(expr) {
    t <- tempfile()
    on.exit(unlink(t))
    cat('library(logger); log_messages(); log_warnings(); log_errors();', file = t)
    cat(expr, file = t, append = TRUE, sep = '\n')
    paste(
        suppressWarnings(system(paste('$R_HOME/bin/Rscript', t, '2>&1'), intern = TRUE)),
        collapse = '\n')
}

test_that('log_messages', {
    expect_match(eval_outside('message(42)'), 'INFO')
    if (R.Version()$os == 'linux-gnu') {
        expect_match(eval_outside('system("echo 42", invisible = TRUE)'), 'INFO')
    }
})

test_that('log_warnings', {
    expect_match(eval_outside('warning(42)'), 'WARN')
    if (R.Version()$major >= 4) {
        expect_match(eval_outside('log(-1)'), 'WARN')
    }
})

test_that('log_errors', {
    expect_match(eval_outside('stop(42)'), 'ERROR')
    if (R.Version()$major >= 4) {
        expect_match(eval_outside('foobar'), 'ERROR')
        expect_match(eval_outside('f<-function(x) {42 * "foobar"}; f()'), 'ERROR')
    }
})
