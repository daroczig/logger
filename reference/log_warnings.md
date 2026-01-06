# Injects a logger call to standard warnings

This function sets a hook to trigger
[`log_warn()`](https://daroczig.github.io/logger/reference/log_level.md)
when `warning` is called to log the warning messages with the global
`logger` layout and appender.

## Usage

``` r
log_warnings(muffle = getOption("logger_muffle_warnings", FALSE))
```

## Arguments

- muffle:

  if TRUE, the warning is not shown after being logged

## Examples

``` r
if (FALSE) { # \dontrun{
log_warnings()
for (i in 1:5) {
  Sys.sleep(runif(1))
  warning(i)
}
} # }
```
