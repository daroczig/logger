test_that("async logging", {
  skip_on_cran()

  t <- withr::local_tempfile()
  local_test_logger(
    layout = layout_blank,
    appender = appender_async(appender_file(file = t))
  )

  for (i in 1:5) log_info(i)
  Sys.sleep(0.25)
  expect_equal(readLines(t)[1], "1")
  expect_equal(length(readLines(t)), 5)
})
