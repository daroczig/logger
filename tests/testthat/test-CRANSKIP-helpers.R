library(logger)
library(testthat)

test_that("tictoc", {
  expect_match(capture.output(log_tictoc(), type = "message"), "timer tic 0 secs")
  ## let time pass a bit
  Sys.sleep(0.01)
  expect_match(capture.output(log_tictoc(), type = "message"), "timer toc")
  capture.output(expect_silent(log_tictoc()), type = "message")
})

test_that("log with separator", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_snapshot({
    log_with_separator(42)
    log_with_separator(42, separator = "|")
  })
})
