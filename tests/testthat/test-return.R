library(logger)
library(testthat)

## save current settings so that we can reset later
formatter <- log_formatter()

context('return value')

log_appender(appender_stdout)

glue_or_sprintf_result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?")

test_that("return value is formatted string", {
  log_formatter(formatter_glue)
  expect_equal(as.character(log_info('pi is {round(pi, 2)}')), 'pi is 3.14')
  log_formatter(formatter_glue_safe)
  everything <- 42
  expect_equal(formatter_glue_safe("Hi {everything}"), "Hi 42")
  log_formatter(formatter_sprintf)
  expect_equal(as.character(log_info("Hi %s", 1:2)), paste("Hi", 1:2))
  log_formatter(formatter_glue_or_sprintf)
  expect_equal(as.character(log_info("Hi %s, did you know that 2*4={2*4}?", c('foo', 'bar'))),
               glue_or_sprintf_result)
  log_formatter(formatter_json)
  expect_equal(as.character(log_info("foo")), '["foo"]')
  expect_equal(as.character(log_info("foo", bar = 42)), '{"1":"foo","bar":42}')
})

## reset settings
log_formatter(formatter)
