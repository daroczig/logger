library(logger)
library(testthat)

context('loggers not to be run while R CMD check')

test_that('namespace in a remote R session to avoid calling from testthat', {

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      log_info("foobar")', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / NA / NA')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      f()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- function() f()
      g()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / f / f()')
    unlink(t)

    t <- tempfile()
    cat('
      library(logger)
      log_layout(layout_glue_generator("{namespace} / {fn} / {call}"))
      f <- function() log_info("foobar")
      g <- f
      g()', file = t)
    expect_equal(
        system(paste('Rscript', t), intern = TRUE),
        'R_GlobalEnv / g / g()')
    unlink(t)

})
