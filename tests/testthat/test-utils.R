test_that("fail_on_missing_package", {
  expect_no_error(fail_on_missing_package("logger"))

  expect_snapshot(error = TRUE, {
    fail_on_missing_package("logger", "9.9.9", call = quote(f()))
    fail_on_missing_package("an.R.package-that-doesNotExists", call = quote(f()))
  })
})

test_that("validate_log_level", {
  expect_equal(validate_log_level(ERROR), ERROR)
  expect_equal(validate_log_level("ERROR"), ERROR)
  expect_snapshot(validate_log_level("FOOBAR"), error = TRUE)
})

test_that("catch_base_log", {
  local_test_logger(layout = layout_simple)
  expect_true(nchar(catch_base_log(ERROR, NA_character_)) == 28)
  expect_true(nchar(catch_base_log(INFO, NA_character_)) == 27)
  local_test_logger(layout = layout_blank)
  expect_true(nchar(catch_base_log(INFO, NA_character_)) == 0)

  local_test_logger(layout = layout_glue_generator(format = "{namespace}/{fn}"))
  expect_equal(catch_base_log(INFO, "TEMP", .topcall = NA), "global/NA")
  expect_equal(catch_base_log(INFO, "TEMP", .topcall = quote(f())), "global/f")
})
