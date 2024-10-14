test_that("append to file", {
  t <- withr::local_tempfile()
  local_test_logger(
    appender = appender_file(t),
    layout = layout_glue_generator("{level} {msg}"),
    threshold = TRACE
  )
  log_info("foobar")
  log_info("{1:2}")
  expect_equal(length(readLines(t)), 3)
  expect_equal(readLines(t)[1], "INFO foobar")
  expect_equal(readLines(t)[3], "INFO 2")
})

test_that("overwrite file", {
  t <- withr::local_tempfile()
  local_test_logger(
    appender = appender_file(t, append = FALSE),
    layout = layout_glue_generator("{level} {msg}"),
    threshold = TRACE
  )

  log_info("foobar")
  log_info("{1:2}")
  expect_equal(length(readLines(t)), 2)
  expect_equal(readLines(t), c("INFO 1", "INFO 2"))

  log_info("42")
  expect_equal(length(readLines(t)), 1)
  expect_equal(readLines(t), "INFO 42")
})

test_that("append to file + print to console", {
  t <- withr::local_tempfile()
  local_test_logger(
    appender = appender_tee(t),
    layout = layout_glue_generator("{level} {msg}"),
  )

  expect_output(log_info("foobar"), "INFO foobar")
  capture.output(log_info("{1:2}"))
  expect_equal(length(readLines(t)), 3)
  expect_equal(readLines(t)[1], "INFO foobar")
})

test_that("logrotate", {
  t <- withr::local_tempdir()
  f <- file.path(t, "log")
  local_test_logger(
    appender = appender_file(f, max_lines = 2, max_files = 5L),
    layout = layout_glue_generator("{msg}"),
    threshold = TRACE
  )

  for (i in 1:24) log_info(i)
  expect_equal(length(readLines(f)), 2)
  expect_equal(length(list.files(t)), 5)
  expect_equal(readLines(f), c("23", "24"))
  log_info("42")
  expect_equal(length(readLines(f)), 1)
  expect_equal(readLines(f), "42")
})
