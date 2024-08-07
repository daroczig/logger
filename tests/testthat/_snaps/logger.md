# setters check inputs

    Code
      log_appender(1)
    Condition
      Error in `log_appender()`:
      ! `appender` must be a function
    Code
      log_formatter(1)
    Condition
      Error in `log_formatter()`:
      ! `formatter` must be a function
    Code
      log_layout(1)
    Condition
      Error in `log_layout()`:
      ! `layout` must be a function
    Code
      log_threshold("x")
    Condition
      Error in `validate_log_level()`:
      ! Invalid log level

