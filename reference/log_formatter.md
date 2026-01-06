# Get or set log message formatter

Get or set log message formatter

## Usage

``` r
log_formatter(formatter = NULL, namespace = "global", index = 1)
```

## Arguments

- formatter:

  function defining how R objects are converted into a single string, eg
  [`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md),
  [`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md),
  [`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md),
  [`formatter_glue_or_sprintf()`](https://daroczig.github.io/logger/reference/formatter_glue_or_sprintf.md),
  [`formatter_logging()`](https://daroczig.github.io/logger/reference/formatter_logging.md),
  default NULL

- namespace:

  logger namespace

- index:

  index of the logger within the namespace

## See also

Other log configutation functions:
[`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md),
[`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md),
[`log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.md)
