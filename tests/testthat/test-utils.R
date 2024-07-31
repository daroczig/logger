library(logger)
library(testthat)

## save current settings so that we can reset later
appender <- log_appender()
log_appender(appender_stdout)

test_that('fail_on_missing_package', {
    expect_error(fail_on_missing_package('logger'), NA)
    expect_error(fail_on_missing_package('logger', '9.9.9'))
    expect_error(fail_on_missing_package('an.R.package-that-doesNotExists'))
})

test_that('except helper', {
    expect_equal(FunDoesNotExist(1:10) %except% sum(1:10) / length(1:10), 5.5)
    expect_output(FunDoesNotExist(1:10) %except% sum(1:10) / length(1:10), 'WARN')
})

test_that('validate_log_level', {
    expect_equal(logger:::validate_log_level(ERROR), ERROR)
    expect_equal(logger:::validate_log_level('ERROR'), ERROR)
    expect_error(logger:::validate_log_level('FOOBAR'), 'log level')
})

test_that('catch_base_log', {
    expect_true(nchar(logger:::catch_base_log(ERROR, NA_character_)) == 28)
    expect_true(nchar(logger:::catch_base_log(INFO, NA_character_)) == 27)
    layout_original <- log_layout()
    log_layout(layout_blank)
    expect_true(nchar(logger:::catch_base_log(INFO, NA_character_)) == 0)
    log_layout(layout_original)
    layout_original <- log_layout(namespace = 'TEMP')
    logger <- layout_glue_generator(format = '{namespace}/{fn} {level}: {msg}')
    log_layout(logger, namespace = 'TEMP')
    expect_true(nchar(logger:::catch_base_log(INFO, 'TEMP', .topcall = NA)) == 14)
    expect_true(nchar(logger:::catch_base_log(INFO, 'TEMP', .topcall = call('5char'))) == 17)
    log_layout(layout_original)
})

## reset settings
log_appender(appender)
