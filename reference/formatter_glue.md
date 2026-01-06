# Apply [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) to convert R objects into a character vector

Apply [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)
to convert R objects into a character vector

## Usage

``` r
formatter_glue(
  ...,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)
```

## Arguments

- ...:

  passed to
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) for
  the text interpolation

- .logcall:

  the logging call being evaluated (useful in formatters and layouts
  when you want to have access to the raw, unevaluated R expression)

- .topcall:

  R expression from which the logging function was called (useful in
  formatters and layouts to extract the calling function's name or
  arguments)

- .topenv:

  original frame of the `.topcall` calling function where the formatter
  function will be evaluated and that is used to look up the `namespace`
  as well via `logger:::top_env_name`

## Value

character vector

## Note

Although this is the default log message formatter function, but when
glue is not installed,
[`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)
will be used as a fallback.

## See also

Other log_formatters:
[`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md),
[`formatter_glue_or_sprintf()`](https://daroczig.github.io/logger/reference/formatter_glue_or_sprintf.md),
[`formatter_glue_safe()`](https://daroczig.github.io/logger/reference/formatter_glue_safe.md),
[`formatter_json()`](https://daroczig.github.io/logger/reference/formatter_json.md),
[`formatter_logging()`](https://daroczig.github.io/logger/reference/formatter_logging.md),
[`formatter_pander()`](https://daroczig.github.io/logger/reference/formatter_pander.md),
[`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md),
[`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)
