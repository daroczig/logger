# Log cumulative running time

This function is working like
[`log_tictoc()`](https://daroczig.github.io/logger/reference/log_tictoc.md)
but differs in that it continues to count up rather than resetting the
timer at every call. You can set the start time using
`log_elapsed_start()`, but if that hasn't been called it will show the
time since the R session started.

## Usage

``` r
log_elapsed(..., level = INFO, namespace = NA_character_)

log_elapsed_start(level = INFO, namespace = NA_character_, quiet = FALSE)
```

## Arguments

- ...:

  passed to
  [`log_level()`](https://daroczig.github.io/logger/reference/log_level.md)

- level:

  see
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- namespace:

  x

- quiet:

  Should starting the time emit a log message

## Examples

``` r
log_elapsed_start()
#> INFO [2026-01-06 21:43:05] starting global timer
Sys.sleep(0.4)
log_elapsed("Tast 1")
#> INFO [2026-01-06 21:43:06] global timer 0.4 secs elapsed -- Tast 1
Sys.sleep(0.2)
log_elapsed("Task 2")
#> INFO [2026-01-06 21:43:06] global timer 0.61 secs elapsed -- Task 2
```
