# Evaluate R expression with a temporarily updated log level threshold

Evaluate R expression with a temporarily updated log level threshold

## Usage

``` r
with_log_threshold(
  expression,
  threshold = ERROR,
  namespace = "global",
  index = 1
)
```

## Arguments

- expression:

  R command

- threshold:

  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- namespace:

  logger namespace

- index:

  index of the logger within the namespace

## Examples

``` r
log_threshold(TRACE)
log_trace("Logging everything!")
#> TRACE [2026-09-09 13:09:01] Logging everything!
x <- with_log_threshold(
  {
    log_info("Now we are temporarily suppressing eg INFO messages")
    log_warn("WARN")
    log_debug("Debug messages are suppressed as well")
    log_error("ERROR")
    invisible(42)
  },
  threshold = WARN
)
#> WARN [2026-09-09 13:09:01] WARN
#> ERROR [2026-09-09 13:09:01] ERROR
x
#> [1] 42
log_trace("DONE")
#> TRACE [2026-09-09 13:09:01] DONE
```
