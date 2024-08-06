# log_messages

    Code
      writeLines(eval_outside("message(42)"))
    Output
      foo
      INFO 42

# log_warnings

    Code
      writeLines(eval_outside("warning(42)"))
    Output
      foo
      WARN 42
    Code
      writeLines(eval_outside("log(-1)"))
    Output
      foo
      WARN NaNs produced

# log_errors

    Code
      writeLines(eval_outside("stop(42)"))
    Output
      foo
      ERROR 42
    Code
      writeLines(eval_outside("foobar"))
    Output
      foo
      ERROR object 'foobar' not found
    Code
      writeLines(eval_outside("f<-function(x) {42 * \"foobar\"}; f()"))
    Output
      foo
      ERROR non-numeric argument to binary operator

# shiny input initialization is detected

    Code
      writeLines(obs)
    Output
      foo
      INFO Loading required package: shiny
      INFO Default Shiny inputs initialized: {}

# shiny input initialization is detected with different log-level

    Code
      writeLines(obs)
    Output
      foo
      INFO Loading required package: shiny
      ERROR Default Shiny inputs initialized: {}

# shiny input change is detected

    Code
      writeLines(obs)
    Output
      foo
      INFO Loading required package: shiny
      INFO Default Shiny inputs initialized: {}
      INFO Shiny input change detected on a: NULL -> 2

# shiny input change is logged with different level

    Code
      writeLines(obs)
    Output
      foo
      INFO Loading required package: shiny
      ERROR Default Shiny inputs initialized: {}
      ERROR Shiny input change detected on a: NULL -> 2

