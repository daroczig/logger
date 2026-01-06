# Format a log record by concatenating the log level, timestamp and message

Format a log record by concatenating the log level, timestamp and
message

## Usage

``` r
layout_simple(
  level,
  msg,
  namespace = NA_character_,
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

- msg:

  string message

- namespace:

  string referring to the `logger` environment / config to be used to
  override the target of the message record to be used instead of the
  default namespace, which is defined by the R package name from which
  the logger was called, and falls back to a common, global namespace.

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

## Value

character vector

## See also

Other log_layouts:
[`get_logger_meta_variables()`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md),
[`layout_blank()`](https://daroczig.github.io/logger/reference/layout_blank.md),
[`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md),
[`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md),
[`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
[`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md),
[`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md),
[`layout_json_parser()`](https://daroczig.github.io/logger/reference/layout_json_parser.md),
[`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md)
