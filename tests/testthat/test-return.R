## save current settings so that we can reset later
formatter <- log_formatter()
appender <- log_appender()

t <- tempfile()
log_appender(appender_file(t))

glue_or_sprintf_result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?")

test_that("return value is formatted string", {
  log_formatter(formatter_glue)
  expect_equal(log_info('pi is {round(pi, 2)}')[[1]]$message, 'pi is 3.14')
  expect_match(log_info('pi is {round(pi, 2)}')[[1]]$record, 'INFO [[0-9: -]*] pi is 3.14')
  log_formatter(formatter_paste, index = 2)
  expect_equal(log_info('pi is {round(pi, 2)}')[[1]]$message, 'pi is 3.14')
  expect_equal(log_info('pi is {round(pi, 2)}')[[2]]$message, 'pi is {round(pi, 2)}')
})

## reset settings
unlink(t)
delete_logger_index(index = 2)
log_formatter(formatter)
log_appender(appender)
