# log_messages

    Code
      writeLines(eval_outside("message(42)"))
    Output
      INFO 42
    Code
      writeLines(eval_outside("system(\"echo 42\", invisible = TRUE)"))
    Output
      INFO arguments 'show.output.on.console', 'minimized' and 'invisible' are for Windows only

# log_warnings

    Code
      writeLines(eval_outside("warning(42)"))
    Output
      WARN 42
    Code
      writeLines(eval_outside("log(-1)"))
    Output
      WARN NaNs produced

# log_errors

    Code
      writeLines(eval_outside("stop(42)"))
    Output
      ERROR 42
    Code
      writeLines(eval_outside("foobar"))
    Output
      ERROR object 'foobar' not found
    Code
      writeLines(eval_outside("f<-function(x) {42 * \"foobar\"}; f()"))
    Output
      ERROR non-numeric argument to binary operator

# shiny input initialization is detected

    Code
      writeLines(obs)
    Output
      INFO Loading required package: shiny
      INFO Default Shiny inputs initialized: {}

# shiny input initialization is detected with different log-level

    Code
      writeLines(obs)
    Output
      INFO Loading required package: shiny
      ERROR Default Shiny inputs initialized: {}

# shiny input change is detected

    Code
      writeLines(obs)
    Output
      INFO Loading required package: shiny
      INFO Default Shiny inputs initialized: {}
      INFO Shiny input change detected on a: NULL -> 2

# shiny input change is logged with different level

    Code
      writeLines(obs)
    Output
      INFO Loading required package: shiny
      ERROR Default Shiny inputs initialized: {}
      ERROR Shiny input change detected on a: NULL -> 2

