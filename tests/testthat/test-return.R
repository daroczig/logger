library(logger)
library(testthat)

context('return value')

glue_or_sprintf_result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?")

test_that("return value is formatted string", {
  local_test_logger(appender = appender_file(withr::local_tempfile()))

  log_formatter(formatter_glue)
  expect_equal(log_info('pi is {round(pi, 2)}')[[1]]$message, 'pi is 3.14')
  expect_match(log_info('pi is {round(pi, 2)}')[[1]]$record, 'INFO [[0-9: -]*] pi is 3.14')
  log_formatter(formatter_paste, index = 2)
  expect_equal(log_info('pi is {round(pi, 2)}')[[1]]$message, 'pi is 3.14')
  expect_equal(log_info('pi is {round(pi, 2)}')[[2]]$message, 'pi is {round(pi, 2)}')
})
