# Mimic the default formatter used in the logging package

The logging package uses a formatter that behaves differently when the
input is a string or other R object. If the first argument is a string,
then [`sprintf()`](https://rdrr.io/r/base/sprintf.html) is being called
– otherwise it does something like
[`log_eval()`](https://daroczig.github.io/logger/reference/log_eval.md)
and logs the R expression(s) and the result(s) as well.

## Usage

``` r
formatter_logging(
  ...,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)
```

## Arguments

- ...:

  string and further params passed to
  [`sprintf()`](https://rdrr.io/r/base/sprintf.html) or R expressions to
  be evaluated

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

## See also

Other log_formatters:
[`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md),
[`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md),
[`formatter_glue_or_sprintf()`](https://daroczig.github.io/logger/reference/formatter_glue_or_sprintf.md),
[`formatter_glue_safe()`](https://daroczig.github.io/logger/reference/formatter_glue_safe.md),
[`formatter_json()`](https://daroczig.github.io/logger/reference/formatter_json.md),
[`formatter_pander()`](https://daroczig.github.io/logger/reference/formatter_pander.md),
[`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md),
[`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)

## Examples

``` r
log_formatter(formatter_logging)
log_info("42")
#> INFO [2026-09-09 13:08:53] 42
log_info(42)
#> INFO [2026-09-09 13:08:53] 42: 42
log_info(4 + 2)
#> INFO [2026-09-09 13:08:53] 4 + 2: 6
log_info("foo %s", "bar")
#> INFO [2026-09-09 13:08:53] foo bar
log_info("vector %s", 1:3)
#> INFO [2026-09-09 13:08:53] vector 1
#> INFO [2026-09-09 13:08:53] vector 2
#> INFO [2026-09-09 13:08:53] vector 3
log_info(12, 1 + 1, 2 * 2)
#> INFO [2026-09-09 13:08:53] 12: 12
#> INFO [2026-09-09 13:08:53] 1 + 1: 2
#> INFO [2026-09-09 13:08:53] 2 * 2: 4
```
