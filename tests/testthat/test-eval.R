library(logger)
library(testthat)

## save current settings so that we can reset later
layout    <- log_layout()
threshold <- log_threshold()
appender  <- log_appender()

log_layout(layout_glue_generator('{level} {msg}'))
log_appender(appender_stdout)

test_that('single line', {
    expect_output(log_eval(4, INFO), sprintf("INFO %s => %s", shQuote(4), shQuote(4)))
})

test_that('multi line', {
    expect_output(log_eval(4, INFO, multiline = TRUE), "Running expression")
    expect_output(log_eval(4, INFO, multiline = TRUE), "Results:")
    expect_output(log_eval(4, INFO, multiline = TRUE), "INFO 4")
})

test_that('invisible return', {
    expect_output(log_eval(require(logger), INFO), sprintf("INFO %s => %s",
                                                           shQuote('require\\(logger\\)'),
                                                           shQuote(TRUE)))
})

log_threshold(TRACE)
test_that('lower log level', {
    expect_output(log_eval(4), sprintf("TRACE %s => %s", shQuote(4), shQuote(4)))
})

## reset settings
log_threshold(threshold)
log_layout(layout)
log_appender(appender)
