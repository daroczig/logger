# log_messages

    Code
      writeLines(eval_outside("log_messages()", "message(42)"))
    Output
      INFO 42

# log_warnings

    Code
      writeLines(eval_outside("log_warnings(TRUE)", "warning(42)", "log(-1)"))
    Output
      WARN 42
      WARN NaNs produced

# log_errors

    Code
      writeLines(eval_outside("log_errors()", "stop(42)"))
    Output
      ERROR 42
    Code
      writeLines(eval_outside("log_errors()", "foobar"))
    Output
      ERROR object 'foobar' not found
    Code
      writeLines(eval_outside("log_errors()", "f<-function(x) {42 * \"foobar\"}; f()"))
    Output
      ERROR non-numeric argument to binary operator

# shiny input initialization is detected

    Code
      writeLines(obs)
    Output
      INFO Default Shiny inputs initialized: {}

# shiny input initialization is detected with different log-level

    Code
      writeLines(obs)
    Output
      ERROR Default Shiny inputs initialized: {}

# shiny input change is detected

    Code
      writeLines(obs)
    Output
      INFO Default Shiny inputs initialized: {}
      INFO Shiny input change detected on a: NULL -> 2

# shiny input change is logged with different level

    Code
      writeLines(obs)
    Output
      ERROR Default Shiny inputs initialized: {}
      ERROR Shiny input change detected on a: NULL -> 2

