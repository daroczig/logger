# Collect useful information about the logging environment to be used in log messages

Available variables to be used in the log formatter functions, eg in
[`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md):

## Usage

``` r
get_logger_meta_variables(
  log_level = NULL,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)
```

## Arguments

- log_level:

  log level as per
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

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

list

## Details

- `levelr`: log level as an R object, eg
  [`INFO()`](https://daroczig.github.io/logger/reference/log_levels.md)

- `level`: log level as a string, eg
  [`INFO()`](https://daroczig.github.io/logger/reference/log_levels.md)

- `time`: current time as `POSIXct`

- `node`: name by which the machine is known on the network as reported
  by `Sys.info`

- `arch`: machine type, typically the CPU architecture

- `os_name`: Operating System's name

- `os_release`: Operating System's release

- `os_version`: Operating System's version

- `user`: name of the real user id as reported by `Sys.info`

- `pid`: the process identification number of the R session

- `node`: name by which the machine is known on the network as reported
  by `Sys.info`

- `r_version`: R's major and minor version as a string

- `ns`: namespace usually defaults to `global` or the name of the
  holding R package of the calling the logging function

- `ns_pkg_version`: the version of `ns` when it's a package

- `ans`: same as `ns` if there's a defined
  [`logger()`](https://daroczig.github.io/logger/reference/logger.md)
  for the namespace, otherwise a fallback namespace (eg usually
  `global`)

- `topenv`: the name of the top environment from which the parent call
  was called (eg R package name or `GlobalEnv`)

- `call`: parent call (if any) calling the logging function

- `location`: A list with element `path` and `line` giving the location
  of the log call

- `fn`: function's (if any) name calling the logging function

## See also

[`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md)

Other log_layouts:
[`layout_blank()`](https://daroczig.github.io/logger/reference/layout_blank.md),
[`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md),
[`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md),
[`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
[`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md),
[`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md),
[`layout_json_parser()`](https://daroczig.github.io/logger/reference/layout_json_parser.md),
[`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md),
[`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)
