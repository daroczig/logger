# Logs the error message to console before failing

Logs the error message to console before failing

## Usage

``` r
log_failure(expression)
```

## Arguments

- expression:

  call

## Examples

``` r
log_failure("foobar")
#> [1] "foobar"
try(log_failure(foobar))
#> ERROR [2026-09-07 21:10:49] object 'foobar' not found
#> Error in eval(expr, envir) : object 'foobar' not found
```
