# Skip the formatter function

Adds the `skip_formatter` attribute to an object so that logger will
skip calling the formatter function(s). This is useful if you want to
preprocess the log message with a custom function instead of the active
formatter function(s). Note that the `message` should be a string, and
`skip_formatter` should be the only input for the logging function to
make this work.

## Usage

``` r
skip_formatter(message, ...)
```

## Arguments

- message:

  character vector directly passed to the appender function in
  [`logger()`](https://daroczig.github.io/logger/reference/logger.md)

- ...:

  should be never set

## Value

character vector with `skip_formatter` attribute set to `TRUE`
