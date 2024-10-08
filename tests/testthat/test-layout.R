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

test_that("must throw errors", {
  expect_error(layout_simple(FOOBAR))
  expect_error(layout_simple(42))
  expect_error(layout_simple(msg = "foobar"))

  expect_error(layout_glue(FOOBAR))
  expect_error(layout_glue(42))
  expect_error(layout_glue(msg = "foobar"))
  expect_error(layout_glue(level = 53, msg = "foobar"))
})

test_that("logging layout", {
  local_test_logger(layout = layout_logging)
  expect_output(log_level(INFO, "foo", namespace = "bar"), "INFO:bar:foo")
  expect_output(log_info("foobar"), "INFO")
  expect_output(log_info("foo", namespace = "bar"), "foo")
  expect_output(log_info("foo", namespace = "bar"), "bar")
  expect_output(log_info("foo", namespace = "bar"), "INFO:bar:foo")
})
