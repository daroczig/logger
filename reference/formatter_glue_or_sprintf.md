# Apply [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) and [`sprintf()`](https://rdrr.io/r/base/sprintf.html)

The best of both words: using both formatter functions in your log
messages, which can be useful eg if you are migrating from
[`sprintf()`](https://rdrr.io/r/base/sprintf.html) formatted log
messages to
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) or
similar.

## Usage

``` r
formatter_glue_or_sprintf(
  msg,
  ...,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)
```

## Arguments

- msg:

  passed to [`sprintf()`](https://rdrr.io/r/base/sprintf.html) as `fmt`
  or handled as part of `...` in
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)

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

## Details

Note that this function tries to be smart when passing arguments to
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) and
[`sprintf()`](https://rdrr.io/r/base/sprintf.html), but might fail with
some edge cases, and returns an unformatted string.

## See also

Other log_formatters:
[`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md),
[`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md),
[`formatter_glue_safe()`](https://daroczig.github.io/logger/reference/formatter_glue_safe.md),
[`formatter_json()`](https://daroczig.github.io/logger/reference/formatter_json.md),
[`formatter_logging()`](https://daroczig.github.io/logger/reference/formatter_logging.md),
[`formatter_pander()`](https://daroczig.github.io/logger/reference/formatter_pander.md),
[`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md),
[`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)

## Examples

``` r
formatter_glue_or_sprintf("{a} + {b} = %s", a = 2, b = 3, 5)
#> [1] "2 + 3 = 5"
formatter_glue_or_sprintf("{pi} * {2} = %s", pi * 2)
#> [1] "3.14159265358979 * 2 = 6.28318530717959"
formatter_glue_or_sprintf("{pi} * {2} = {pi*2}")
#> [1] "3.14159265358979 * 2 = 6.28318530717959"

formatter_glue_or_sprintf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}")
#> [1] "Hi foo, did you know that 2*4=8" "Hi bar, did you know that 2*4=8"
formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}")
#> [1] "Hi foo, did you know that 2*4=8" "Hi bar, did you know that 2*4=8"
formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4=%s", 2 * 4)
#> [1] "Hi foo, did you know that 2*4=8" "Hi bar, did you know that 2*4=8"
formatter_glue_or_sprintf("Hi %s, did you know that 2*4={2*4}", c("foo", "bar"))
#> [1] "Hi foo, did you know that 2*4=8" "Hi bar, did you know that 2*4=8"
formatter_glue_or_sprintf("Hi %s, did you know that 2*4=%s", c("foo", "bar"), 2 * 4)
#> [1] "Hi foo, did you know that 2*4=8" "Hi bar, did you know that 2*4=8"
```
