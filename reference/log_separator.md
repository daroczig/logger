# Logs a long line to stand out from the console

Logs a long line to stand out from the console

## Usage

``` r
log_separator(
  level = INFO,
  namespace = NA_character_,
  separator = "=",
  width = 80,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)
```

## Arguments

- level:

  log level, see
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)
  for more details

- namespace:

  string referring to the `logger` environment / config to be used to
  override the target of the message record to be used instead of the
  default namespace, which is defined by the R package name from which
  the logger was called, and falls back to a common, global namespace.

- separator:

  character to be used as a separator

- width:

  max width of message – longer text will be wrapped into multiple lines

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

- .timestamp:

  The time the logging occured. Defaults to the current time but may be
  overwritten if the logging is delayed from the time it happend

## See also

[`log_with_separator()`](https://daroczig.github.io/logger/reference/log_with_separator.md)

## Examples

``` r
log_separator()
#> INFO [2026-09-07 21:10:50] =====================================================
log_separator(ERROR, separator = "!", width = 60)
#> ERROR [2026-09-07 21:10:50] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
log_separator(ERROR, separator = "!", width = 100)
#> ERROR [2026-09-07 21:10:50] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
log_layout(logger)
log_separator(ERROR, separator = "!", width = 100)
#> runnervmejwal/8563/global/eval 2026-09-07 21:10:50.537484 ERROR: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
log_layout(layout_blank)
log_separator(ERROR, separator = "!", width = 80)
#> !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
```
