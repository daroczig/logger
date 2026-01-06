# Log a message with given log level

Log a message with given log level

## Usage

``` r
log_level(
  level,
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_fatal(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_error(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_warn(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_success(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_info(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_debug(
  ...,
  namespace = NA_character_,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame(),
  .timestamp = Sys.time()
)

log_trace(
  ...,
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

- ...:

  R objects that can be converted to a character vector via the active
  message formatter function

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

Invisible `list` of `logger` objects. See
[`logger()`](https://daroczig.github.io/logger/reference/logger.md) for
more details on the format.

## Examples

``` r
log_level(INFO, "hi there")
#> INFO [2026-01-06 21:43:08] hi there
log_info("hi there")
#> INFO [2026-01-06 21:43:08] hi there

## output omitted
log_debug("hi there")

## lower threshold and retry
log_threshold(TRACE)
log_debug("hi there")
#> DEBUG [2026-01-06 21:43:08] hi there

## multiple lines
log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#> INFO [2026-01-06 21:43:08] ok 1 + 1 = 2
#> INFO [2026-01-06 21:43:08] ok 2 + 2 = 4
#> INFO [2026-01-06 21:43:08] ok 3 + 3 = 6

## use json layout
log_layout(layout_json(c("time", "level")))
log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#> {"time":"2026-01-06 21:43:08","level":"INFO","msg":"ok 1 + 1 = 2"}
#> {"time":"2026-01-06 21:43:08","level":"INFO","msg":"ok 2 + 2 = 4"}
#> {"time":"2026-01-06 21:43:08","level":"INFO","msg":"ok 3 + 3 = 6"}
```
