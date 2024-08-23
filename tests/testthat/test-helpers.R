test_that("separator", {
  local_test_logger(layout = layout_blank)
  expect_output(log_separator(), "={80,80}")

  local_test_logger()
  expect_output(log_separator(separator = "-"), "---")
  expect_output(log_separator(), "INFO")
  expect_output(log_separator(WARN), "WARN")
})

test_that("tictoc", {
  expect_match(capture.output(log_tictoc(), type = "message"), "timer tic 0 secs")
  ## let time pass a bit
  Sys.sleep(0.01)
  expect_match(capture.output(log_tictoc(), type = "message"), "timer toc")
  capture.output(expect_silent(log_tictoc()), type = "message")
})

test_that("log with separator", {
  local_test_logger()
  expect_output(log_with_separator(42), "===")
  expect_output(log_with_separator("Boo!", level = FATAL, width = 120), width = 120)
})

test_that("log with separator", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_snapshot({
    log_with_separator(42)
    log_with_separator(42, separator = "|")
  })
})


test_that("log failure", {
  local_test_logger()
  expect_output(log_failure("foobar"), NA)
  expect_output(try(log_failure(foobar), silent = TRUE), "ERROR.*foobar")
  expect_error(log_failure("foobar"), NA)
  expect_match(capture.output(expect_error(log_failure(foobar))), "not found")
})
