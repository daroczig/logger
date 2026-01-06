# Generate logging utility

A logger consists of a log level `threshold`, a log message `formatter`
function, a log record `layout` formatting function and the `appender`
function deciding on the destination of the log record. For more
details, see the package `README.md`.

## Usage

``` r
logger(threshold, formatter, layout, appender)
```

## Arguments

- threshold:

  omit log messages below this
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- formatter:

  function pre-processing the message of the log record when it's not
  wrapped in a
  [`skip_formatter()`](https://daroczig.github.io/logger/reference/skip_formatter.md)
  call

- layout:

  function rendering the layout of the actual log record

- appender:

  function writing the log record

## Value

A function taking the log `level` to compare with the set threshold, all
the `...` arguments passed to the formatter function, besides the
standard `namespace`, `.logcall`, `.topcall` and `.topenv` arguments
(see
[`log_level()`](https://daroczig.github.io/logger/reference/log_level.md)
for more details). The function invisibly returns a list including the
original `level`, `namespace`, all `...` transformed to a list as
`params`, the log `message` (after calling the `formatter` function) and
the log `record` (after calling the `layout` function), and a list of
`handlers` with the `formatter`, `layout` and `appender` functions.

## Details

By default, a general logger definition is created when loading the
`logger` package, that uses

- [`INFO()`](https://daroczig.github.io/logger/reference/log_levels.md)
  (or as per the `LOGGER_LOG_LEVEL` environment variable override) as
  the log level threshold

- [`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)
  as the layout function showing the log level, timestamp and log
  message

- [`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md)
  (or
  [`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)
  if glue is not installed) as the default formatter function
  transforming the R objects to be logged to a character vector

- [`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md)
  as the default log record destination

## Note

It's quite unlikely that you need to call this function directly, but
instead set the logger parameters and functions at
[`log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.md),
[`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md),
[`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md)
and
[`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md)
and then call
[`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)
and its derivatives, such as
[`log_info()`](https://daroczig.github.io/logger/reference/log_level.md)
directly.

## References

For more details, see the Anatomy of a Log Request vignette at
<https://daroczig.github.io/logger/articles/anatomy.html>.

## Examples

``` r
if (FALSE) { # \dontrun{
do.call(logger, logger:::namespaces$global[[1]])(INFO, 42)
do.call(logger, logger:::namespaces$global[[1]])(INFO, "{pi}")
x <- 42
do.call(logger, logger:::namespaces$global[[1]])(INFO, "{x}^2 = {x^2}")
} # }
```
