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
    Code
      writeLines(eval_outside("log_errors(traceback = TRUE)",
        "f<-function() stop(\"TEST\"); f()"))
    Output
      ERROR TEST
      ERROR Traceback:
      ERROR 2: stop("TEST")
      ERROR 1: f()

# shiny input initialization is detected

    Code
      writeLines(obs)
    Output
      INFO mock-session Default Shiny inputs initialized: {}

# shiny input initialization is detected with different log-level

    Code
      writeLines(obs)
    Output
      ERROR mock-session Default Shiny inputs initialized: {}

# shiny input change is detected

    Code
      writeLines(obs)
    Output
      INFO mock-session Default Shiny inputs initialized: {}
      INFO mock-session Shiny input change detected in a: NULL -> 2

# shiny input change is logged with different level

    Code
      writeLines(obs)
    Output
      ERROR mock-session Default Shiny inputs initialized: {}
      ERROR mock-session Shiny input change detected in a: NULL -> 2

