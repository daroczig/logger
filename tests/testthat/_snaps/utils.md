# fail_on_missing_package

    Code
      fail_on_missing_package("logger", "9.9.9", call = quote(f()))
    Condition
      Error:
      ! Please install min. 9.9.9 version of logger to use f
    Code
      fail_on_missing_package("an.R.package-that-doesNotExists", call = quote(f()))
    Condition
      Error:
      ! Please install the 'an.R.package-that-doesNotExists' package to use f

# validate_log_level

    Code
      validate_log_level("FOOBAR")
    Condition
      Error in `validate_log_level()`:
      ! Invalid log level

