# Injects a logger call to standard errors

This function sets a hook to trigger
[`log_error()`](https://daroczig.github.io/logger/reference/log_level.md)
when [`stop()`](https://rdrr.io/r/base/stop.html) is called to log the
error messages with the global `logger` layout and appender.

## Usage

``` r
log_errors(
  muffle = getOption("logger_muffle_errors", FALSE),
  traceback = FALSE
)
```

## Arguments

- muffle:

  if TRUE, the error is not thrown after being logged

- traceback:

  if TRUE the error traceback is logged along with the error message

## Examples

``` r
if (FALSE) { # \dontrun{
log_errors()
stop("foobar")
} # }
```
