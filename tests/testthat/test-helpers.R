library(logger)
library(testthat)

## save current settings so that we can reset later
appender <- log_appender()

log_appender(appender_stdout)

context('helpers')

test_that('separator', {
    original_layout <- log_layout()
    log_layout(layout_blank)
    expect_output(log_separator(), '={80,80}')
    log_layout(original_layout)
    expect_output(log_separator(separator = '-'), '---')
    expect_output(log_separator(), 'INFO')
    expect_output(log_separator(WARN), 'WARN')
})

test_that('tictoc', {
    expect_output(log_tictoc(), 'timer')
})

test_that('log with separator', {
    expect_output(log_with_separator(42), '===')
    logger <- layout_glue_generator(format = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
    layout_original <- log_layout()
    log_layout(logger)
    expect_output(log_with_separator('Boo!', level = FATAL, width = 120), width = 120)
    log_layout(layout_original)
})

test_that('log failure', {
  expect_output(log_failure("foobar"), NA)
  expect_output(try(log_failure(foobar), silent = TRUE), 'ERROR.*foobar')
  expect_error(log_failure('foobar'), NA)
  expect_match(capture.output(expect_error(log_failure(foobar))), 'not found')
})

## reset settings
log_appender(appender)
