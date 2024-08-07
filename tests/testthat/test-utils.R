test_that('fail_on_missing_package', {
    expect_error(fail_on_missing_package('logger'), NA)
    expect_error(fail_on_missing_package('logger', '9.9.9'))
    expect_error(fail_on_missing_package('an.R.package-that-doesNotExists'))
})

test_that('validate_log_level', {
    expect_equal(validate_log_level(ERROR), ERROR)
    expect_equal(validate_log_level('ERROR'), ERROR)
    expect_error(validate_log_level('FOOBAR'), 'log level')
})

test_that('catch_base_log', {
    expect_true(nchar(catch_base_log(ERROR, NA_character_)) == 28)
    expect_true(nchar(catch_base_log(INFO, NA_character_)) == 27)
    local_test_logger(layout = layout_blank)
    expect_true(nchar(catch_base_log(INFO, NA_character_)) == 0)

    local_test_logger(
      layout = layout_glue_generator(format = '{namespace}/{fn} {level}: {msg}'),
      namespace = "TEMP"
    )
    expect_true(nchar(catch_base_log(INFO, 'TEMP', .topcall = NA)) == 14)
    expect_true(nchar(catch_base_log(INFO, 'TEMP', .topcall = call('5char'))) == 17)
})
