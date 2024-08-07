test_that("single line", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_output(log_eval(4, INFO), sprintf("INFO %s => %s", shQuote(4), shQuote(4)))
})

test_that("multi line", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_output(log_eval(4, INFO, multiline = TRUE), "Running expression")
  expect_output(log_eval(4, INFO, multiline = TRUE), "Results:")
  expect_output(log_eval(4, INFO, multiline = TRUE), "INFO 4")
})

test_that("invisible return", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))
  expect_output(log_eval(require(logger), INFO), sprintf(
    "INFO %s => %s",
    shQuote("require\\(logger\\)"),
    shQuote(TRUE)
  ))
})

test_that("lower log level", {
  local_test_logger(TRACE, layout = layout_glue_generator("{level} {msg}"))
  expect_output(log_eval(4), sprintf("TRACE %s => %s", shQuote(4), shQuote(4)))
})
