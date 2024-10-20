# log failure

    Code
      capture.output(log_failure(foobar))
    Condition
      Error:
      ! object 'foobar' not found

# log with separator

    Code
      log_with_separator(42)
    Output
      INFO ===========================================================================
      INFO = 42                                                                      =
      INFO ===========================================================================
    Code
      log_with_separator(42, separator = "|")
    Output
      INFO |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      INFO | 42                                                                      |
      INFO |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

