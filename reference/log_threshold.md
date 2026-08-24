# Get or set log level threshold

Get or set log level threshold

## Usage

``` r
log_threshold(level = NULL, namespace = "global", index = 1)
```

## Arguments

- level:

  see
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- namespace:

  logger namespace

- index:

  index of the logger within the namespace

## Value

currently set log level threshold

## See also

Other log configutation functions:
[`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md),
[`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md),
[`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md)

## Examples

``` r
## check the currently set log level threshold
log_threshold()
#> Log level: INFO

## change the log level threshold to WARN
log_threshold(WARN)
log_info(1)
log_warn(2)
#> WARN [2026-08-24 12:19:40] 2

## add another logger with a lower log level threshold and check the number of logged messages
log_threshold(INFO, index = 2)
log_info(1)
#> INFO [2026-08-24 12:19:40] 1
log_warn(2)
#> WARN [2026-08-24 12:19:40] 2
#> WARN [2026-08-24 12:19:40] 2

## set the log level threshold in all namespaces to ERROR
log_threshold(ERROR, namespace = log_namespaces())
```
