library(logger)
library(testthat)

## save current settings so that we can reset later
layout <- log_layout()
log_layout(layout_glue_generator('{level} {msg}'))

context('log_eval')
test_that('single line', {
    expect_output(log_eval(4, INFO), "INFO '4' => '4'")
})
test_that('multi line', {
    expect_output(log_eval(4, INFO, multiline = TRUE), "Running expression")
    expect_output(log_eval(4, INFO, multiline = TRUE), "Results:")
    expect_output(log_eval(4, INFO, multiline = TRUE), "INFO 4")
})

## reset settings
log_layout(layout)
