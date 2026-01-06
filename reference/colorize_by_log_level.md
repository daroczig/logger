# Color string by the related log level

Color log messages according to their severity with either a rainbow or
grayscale color scheme. The greyscale theme assumes a dark background on
the terminal.

## Usage

``` r
colorize_by_log_level(msg, level)

grayscale_by_log_level(msg, level)
```

## Arguments

- msg:

  String to color.

- level:

  see
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

## Value

A string with ANSI escape codes.

## Examples

``` r
cat(colorize_by_log_level("foobar", FATAL), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", ERROR), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", WARN), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", SUCCESS), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", INFO), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", DEBUG), "\n")
#> foobar 
cat(colorize_by_log_level("foobar", TRACE), "\n")
#> foobar 

cat(grayscale_by_log_level("foobar", FATAL), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", ERROR), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", WARN), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", SUCCESS), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", INFO), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", DEBUG), "\n")
#> foobar 
cat(grayscale_by_log_level("foobar", TRACE), "\n")
#> foobar 
```
