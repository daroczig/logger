test_that("blank layout", {
  local_test_logger(layout = layout_blank)
  expect_output(log_info("foobar"), "foobar")
  expect_equal(capture.output(log_info("foobar")), "foobar")
})

test_that("colorized layout", {
  local_test_logger(layout = layout_glue_colors)
  expect_output(log_info("foobar"), "INFO")
  expect_output(log_info("foobar"), "foobar")
  expect_output(log_error("foobar"), "ERROR")
  expect_output(log_error("foobar"), "foobar")
})

test_that("metavars", {
  local_test_logger(layout = layout_glue_generator("{level} {ans} {fn}"))

  f_info <- function() log_info()
  expect_output(f_info(), "INFO global f_info()")

  f_warn <- function() log_warn()
  expect_output(f_warn(), "WARN global f_warn()")
})

test_that("JSON layout", {
  local_test_logger(layout = layout_json(fields = "level"))

  out <- jsonlite::fromJSON(capture.output(log_info("foobar")))
  expect_equal(out, list(level = "INFO", msg = "foobar"))
})

test_that("JSON layout warns if you include msg", {
  expect_snapshot(layout <- layout_json(fields = "msg"))
  local_test_logger(layout = layout)
  out <- jsonlite::fromJSON(capture.output(log_info("foobar")))
  expect_equal(out, list(msg = "foobar"))
})

test_that("JSON parser layout", {
  local_test_logger(layout = layout_json_parser(fields = character()))
  expect_output(log_info(skip_formatter('{"x": 4}')), '{"x":4}', fixed = TRUE)
})

test_that("JSON parser layout can be renamed", {
  local_test_logger(layout = layout_json_parser(c(LEVEL = "level")))
  expect_output(log_info(skip_formatter('{"x": 4}')), '{"LEVEL":"INFO","x":4}', fixed = TRUE)
})

test_that("must throw errors", {
  skip_if_not(getRversion() >= "4.3") # error call changed

  expect_snapshot(error = TRUE, {
    layout_simple(FOOBAR)
    layout_simple(42)
    layout_simple(msg = "foobar")
  })

  expect_snapshot(error = TRUE, {
    layout_glue(FOOBAR)
    layout_glue(42)
    layout_glue(msg = "foobar")
    layout_glue(level = 53, msg = "foobar")
  })
})

test_that("logging layout", {
  local_test_logger(layout = layout_logging)
  expect_output(log_level(INFO, "foo", namespace = "bar"), "INFO:bar:foo")
  expect_output(log_info("foobar"), "INFO")
  expect_output(log_info("foo", namespace = "bar"), "foo")
  expect_output(log_info("foo", namespace = "bar"), "bar")
  expect_output(log_info("foo", namespace = "bar"), "INFO:bar:foo")
})

test_that("log_info() captures local info", {
  local_test_logger(
    layout = layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}")
  )
  f <- function() log_info("foobar")
  g <- function() f()

  expect_snapshot({
    log_info("foobar")
    f()
    g()
  })
})

test_that("log_info() captures package info", {
  devtools::load_all(
    system.file("demo-packages/logger-tester-package", package = "logger"),
    quiet = TRUE
  )
  withr::defer(devtools::unload("logger.tester"))

  local_test_logger(layout = layout_glue_generator("{ns} {level} {msg}"))
  expect_snapshot({
    logger_tester_function(INFO, "x = ")
    logger_info_tester_function("everything = ")
  })
})

test_that("timestamp can be formatted", {
  layouts <- list(
    layout_glue_generator("{time}"),
    # layout_blank, # blank layout does not print time
    layout_simple,
    layout_logging,
    # layout_glue, # time-foramt is fixed
    # layout_glue_colors, # time-foramt is fixed
    layout_json(fields = "time")
  )

  withr::with_options(
    list(`logger.format_time` = function(x) format(x, "global %Z", tz = "UTC")),
    {
      for (layout in layouts) {
        local_test_logger(layout = layout, formatter = formatter_json)
        expect_snapshot(log_info())
      }
    }
  )
})
