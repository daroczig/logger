# Get or set log record appender function

Get or set log record appender function

## Usage

``` r
log_appender(appender = NULL, namespace = "global", index = 1)
```

## Arguments

- appender:

  function delivering a log record to the destination, eg
  [`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
  [`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md)
  or
  [`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
  default NULL

- namespace:

  logger namespace

- index:

  index of the logger within the namespace

## See also

Other log configutation functions:
[`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md),
[`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md),
[`log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.md)

## Examples

``` r
## change appender to "tee" that writes to the console and a file as well
t <- tempfile()
log_appender(appender_tee(t))
log_info(42)
#> INFO [2026-08-24 12:26:31] 42
log_info(43)
#> INFO [2026-08-24 12:26:31] 43
log_info(44)
#> INFO [2026-08-24 12:26:31] 44
readLines(t)
#> [1] "INFO [2026-08-24 12:26:31] 42" "INFO [2026-08-24 12:26:31] 43"
#> [3] "INFO [2026-08-24 12:26:31] 44"

## poor man's tee by stacking loggers in the namespace
t <- tempfile()
log_appender(appender_stdout)
log_appender(appender_file(t), index = 2)
log_info(42)
#> INFO [2026-08-24 12:26:31] 42
readLines(t)
#> [1] "INFO [2026-08-24 12:26:31] 42"
```
