# Tic-toc logging

Tic-toc logging

## Usage

``` r
log_tictoc(..., level = INFO, namespace = NA_character_)
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

## Author

Thanks to Neal Fultz for the idea and original implementation!

## Examples

``` r
log_tictoc("warming up")
#> INFO [2026-05-09 19:42:22] global timer tic 0 secs -- warming up
Sys.sleep(0.1)
log_tictoc("running")
#> INFO [2026-05-09 19:42:22] global timer toc 0.1 secs -- running
Sys.sleep(0.1)
log_tictoc("running")
#> INFO [2026-05-09 19:42:22] global timer toc 0.1 secs -- running
Sys.sleep(runif(1))
log_tictoc("and running")
#> INFO [2026-05-09 19:42:23] global timer toc 0.93 secs -- and running
```
