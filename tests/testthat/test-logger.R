test_that("log levels", {
  local_test_logger(WARN)

  expect_output(log_fatal("foo"), "FATAL.*foo")
  expect_output(log_error("foo"), "ERROR.*foo")
  expect_output(log_warn("foo"), "WARN.*foo")
  expect_output(log_success("foo"), NA)
  expect_output(log_info("foo"), NA)
  expect_output(log_debug("foo"), NA)
  expect_output(log_trace("foo"), NA)
  expect_output(log_level("ERROR", "foo"), "ERROR.*foo")
  expect_output(log_level(ERROR, "foo"), "ERROR.*foo")
  expect_output(log_level(as.loglevel(ERROR), "foo"), "ERROR.*foo")
  expect_output(log_level(as.loglevel("ERROR"), "foo"), "ERROR.*foo")
  expect_output(log_level(as.loglevel(200L), "foo"), "ERROR.*foo")
  expect_output(log_level("TRACE", "foo"), NA)
  expect_output(log_level(TRACE, "foo"), NA)
  expect_output(log_level(as.loglevel(TRACE), "foo"), NA)
  expect_output(log_level(as.loglevel("TRACE"), "foo"), NA)
  expect_output(log_level(as.loglevel(600L), "foo"), NA)
})

test_that("log levels - OFF", {
  local_test_logger(OFF)
  expect_output(log_fatal("foo"), NA)
  expect_output(log_error("foo"), NA)
  expect_output(log_warn("foo"), NA)
  expect_output(log_success("foo"), NA)
  expect_output(log_info("foo"), NA)
  expect_output(log_debug("foo"), NA)
  expect_output(log_trace("foo"), NA)
})

test_that("log thresholds", {
  local_test_logger(TRACE)
  expect_output(log_fatal("foo"), "FATAL.*foo")
  expect_output(log_error("foo"), "ERROR.*foo")
  expect_output(log_warn("foo"), "WARN.*foo")
  expect_output(log_success("foo"), "SUCCESS.*foo")
  expect_output(log_info("foo"), "INFO.*foo")
  expect_output(log_debug("foo"), "DEBUG.*foo")
  expect_output(log_trace("foo"), "TRACE.*foo")
})

test_that("with log thresholds", {
  local_test_logger(WARN)
  expect_output(with_log_threshold(log_fatal("foo"), threshold = TRACE), "FATAL.*foo")
  expect_output(with_log_threshold(log_error("foo"), threshold = TRACE), "ERROR.*foo")
  expect_output(with_log_threshold(log_error("foo"), threshold = FATAL), NA)
  expect_output(with_log_threshold(log_error("foo"), threshold = INFO), "ERROR.*foo")
  expect_output(with_log_threshold(log_debug("foo"), threshold = INFO), NA)
})

test_that("simple glue layout with no threshold", {
  local_test_logger(TRACE, layout = layout_glue_generator("{level} {msg}"))

  expect_equal(capture.output(log_fatal("foobar")), "FATAL foobar")
  expect_equal(capture.output(log_error("foobar")), "ERROR foobar")
  expect_equal(capture.output(log_warn("foobar")), "WARN foobar")
  expect_equal(capture.output(log_info("foobar")), "INFO foobar")
  expect_equal(capture.output(log_debug("foobar")), "DEBUG foobar")
  expect_equal(capture.output(log_trace("foobar")), "TRACE foobar")
})

test_that("simple glue layout with threshold", {
  local_test_logger(INFO, layout = layout_glue_generator("{level} {msg}"))
  expect_equal(capture.output(log_fatal("foobar")), "FATAL foobar")
  expect_equal(capture.output(log_error("foobar")), "ERROR foobar")
  expect_equal(capture.output(log_warn("foobar")), "WARN foobar")
  expect_equal(capture.output(log_info("foobar")), "INFO foobar")
  expect_equal(capture.output(log_debug("foobar")), character())
  expect_equal(capture.output(log_trace("foobar")), character())
})

test_that("namespaces", {
  local_test_logger(ERROR, namespace = "custom", layout = layout_glue_generator("{level} {msg}"))
  expect_output(log_fatal("foobar", namespace = "custom"), "FATAL foobar")
  expect_output(log_error("foobar", namespace = "custom"), "ERROR foobar")
  expect_output(log_info("foobar", namespace = "custom"), NA)
  expect_output(log_debug("foobar", namespace = "custom"), NA)

  local_test_logger(INFO, namespace = "custom", layout = layout_glue_generator("{level} {msg}"))
  expect_output(log_info("foobar", namespace = "custom"), "INFO foobar")
  expect_output(log_debug("foobar", namespace = "custom"), NA)

  log_threshold(TRACE, namespace = log_namespaces())
  expect_output(log_debug("foobar", namespace = "custom"), "DEBUG foobar")
})

test_that("simple glue layout with threshold directly calling log", {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))
  expect_equal(capture.output(log_level(FATAL, "foobar")), "FATAL foobar")
  expect_equal(capture.output(log_level(ERROR, "foobar")), "ERROR foobar")
  expect_equal(capture.output(log_level(WARN, "foobar")), "WARN foobar")
  expect_equal(capture.output(log_level(INFO, "foobar")), "INFO foobar")
  expect_equal(capture.output(log_level(DEBUG, "foobar")), character())
  expect_equal(capture.output(log_level(TRACE, "foobar")), character())
})

test_that("built in variables: pid", {
  local_test_logger(layout = layout_glue_generator("{pid}"))
  expect_equal(capture.output(log_info("foobar")), as.character(Sys.getpid()))
})

test_that("built in variables: fn and call", {
  local_test_logger(layout = layout_glue_generator("{fn} / {call}"))
  f <- function() log_info("foobar")
  expect_output(f(), "f / f()")
  g <- function() f()
  expect_output(g(), "f / f()")
  g <- f
  expect_output(g(), "g / g()")
})

test_that("built in variables: namespace", {
  local_test_logger(layout = layout_glue_generator("{ns}"))
  expect_output(log_info("bar", namespace = "foo"), "foo")

  local_test_logger(layout = layout_glue_generator("{ans}"))
  expect_output(log_info("bar", namespace = "foo"), "global")
})

test_that("print.level", {
  expect_equal(capture.output(print(INFO)), "Log level: INFO")
})

test_that("config setter called from do.call", {
  local_test_logger()

  t <- withr::local_tempfile()
  expect_no_error(do.call(log_appender, list(appender_file(t))))
  log_info(42)
  expect_length(readLines(t), 1)
  expect_no_error(do.call(log_threshold, list(ERROR)))
  log_info(42)
  expect_length(readLines(t), 1)
  expect_no_error(do.call(log_threshold, list(INFO)))
  log_info(42)
  expect_length(readLines(t), 2)
  expect_no_error(do.call(log_layout, list(formatter_paste)))
  log_info(42)
  expect_length(readLines(t), 3)
})

test_that("providing log_level() args to wrappers diretly is OK", {
  local_test_logger(WARN)
  expect_silent(log_info("{Sepal.Length}", .topenv = iris))
})

test_that("setters check inputs", {
  expect_snapshot(error = TRUE, {
    log_appender(1)
    log_formatter(1)
    log_layout(1)
    log_threshold("x")
  })
})
