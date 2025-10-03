test_that("separator", {
  local_test_logger(layout = layout_blank)
  expect_output(log_separator(), "={80,80}")

  local_test_logger()
  expect_output(log_separator(separator = "-"), "---")
  expect_output(log_separator(), "INFO")
  expect_output(log_separator(WARN), "WARN")
})

test_that("tictoc", {
  local_test_logger()
  local_mocked_bindings(Sys.time = function() as.POSIXct("2024-01-01 00:00:00"))
  expect_output(log_tictoc(), "timer tic 0 secs")
  ## simulate time passing
  local_mocked_bindings(Sys.time = function() as.POSIXct("2024-01-01 00:01:00"))
  expect_output(log_tictoc(), "timer toc 1 mins")
})

test_that("elapsed", {
  local_test_logger()

  proc_null <- proc.time() * 0

  with_mocked_bindings(
    expect_output(log_elapsed(), "timer 2 secs elapsed"),
    proc.time = function() proc_null + 2
  )

  with_mocked_bindings(
    expect_output(log_elapsed_start(), "starting global timer"),
    proc.time = function() proc_null + 1
  )

  with_mocked_bindings(
    expect_output(log_elapsed(), "timer 1 secs elapsed"),
    proc.time = function() proc_null + 2
  )

  with_mocked_bindings(
    expect_silent(log_elapsed_start(quiet = TRUE)),
    proc.time = function() proc_null
  )
})

test_that("log with separator", {
  local_test_logger()
  expect_output(log_with_separator(42), "===")
  expect_output(log_with_separator("Boo!", level = FATAL, width = 120), width = 120)
})

test_that("log failure", {
  skip_if_not(getRversion() >= "4.3") # error call changed

  local_test_logger()
  expect_output(log_failure("foobar"), NA)
  expect_output(try(log_failure(foobar), silent = TRUE), "ERROR.*foobar")
  expect_no_error(log_failure("foobar"))
  expect_snapshot(capture.output(log_failure(foobar)), error = TRUE)
})

test_that("log with separator", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))

  expect_snapshot({
    log_with_separator(42)
    log_with_separator(42, separator = "|")
  })
})


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

test_that("knitr hook gets applied", {
  local_test_logger()
  mock_doc <- c(
    "```{r, include = FALSE}",
    "library(logger)",
    "log_chunk_time()",
    "```",
    "```{r}",
    "Sys.sleep(0.2)",
    "```"
  )
  expect_output(knitr::knit(text = mock_doc, quiet = TRUE), "global timer [0-9\\.]* secs elapsed")
})
