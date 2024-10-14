test_that("tictoc", {
  local_test_logger()
  local_mocked_bindings(Sys.time = function() as.POSIXct("2024-01-01 00:00:00"))

  expect_output(log_tictoc(), "timer tic 0 secs")
  ## simulate time passing
  local_mocked_bindings(Sys.time = function() as.POSIXct("2024-01-01 00:01:00"))
  expect_output(log_tictoc(), "timer toc 1 mins")
  expect_output(log_tictoc(), "timer tic 0 secs")
})

test_that("log with separator", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_snapshot({
    log_with_separator(42)
    log_with_separator(42, separator = "|")
  })
})
