# Logs a message in a very visible way

Logs a message in a very visible way

## Usage

``` r
log_with_separator(
  ...,
  level = INFO,
  namespace = NA_character_,
  separator = "=",
  width = 80
)
```

## Arguments

- ...:

  R objects that can be converted to a character vector via the active
  message formatter function

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

## See also

[`log_separator()`](https://daroczig.github.io/logger/reference/log_separator.md)

## Examples

``` r
log_with_separator("An important message")
#> INFO [2026-08-24 12:19:42] =====================================================
#> INFO [2026-08-24 12:19:42] = An important message                              =
#> INFO [2026-08-24 12:19:42] =====================================================
log_with_separator("Some critical KPI down!!!", separator = "$")
#> INFO [2026-08-24 12:19:42] $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#> INFO [2026-08-24 12:19:42] $ Some critical KPI down!!!                         $
#> INFO [2026-08-24 12:19:42] $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
log_with_separator("This message is worth a {1e3} words")
#> INFO [2026-08-24 12:19:42] =====================================================
#> INFO [2026-08-24 12:19:42] = This message is worth a 1000 words                =
#> INFO [2026-08-24 12:19:42] =====================================================
log_with_separator(paste(
  "A very important message with a bunch of extra words that will",
  "eventually wrap into a multi-line message for our quite nice demo :wow:"
))
#> INFO [2026-08-24 12:19:42] =====================================================
#> INFO [2026-08-24 12:19:42] = A very important message with a bunch of extra    =
#> INFO [2026-08-24 12:19:42] = words that will eventually wrap into a            =
#> INFO [2026-08-24 12:19:42] = multi-line message for our quite nice demo :wow:  =
#> INFO [2026-08-24 12:19:42] =====================================================
log_with_separator(
  paste(
    "A very important message with a bunch of extra words that will",
    "eventually wrap into a multi-line message for our quite nice demo :wow:"
  ),
  width = 60
)
#> INFO [2026-08-24 12:19:42] =================================
#> INFO [2026-08-24 12:19:42] = A very important message      =
#> INFO [2026-08-24 12:19:42] = with a bunch of extra words   =
#> INFO [2026-08-24 12:19:42] = that will eventually wrap     =
#> INFO [2026-08-24 12:19:42] = into a multi-line message     =
#> INFO [2026-08-24 12:19:42] = for our quite nice demo       =
#> INFO [2026-08-24 12:19:42] = :wow:                         =
#> INFO [2026-08-24 12:19:42] =================================
log_with_separator("Boo!", level = FATAL)
#> FATAL [2026-08-24 12:19:42] ====================================================
#> FATAL [2026-08-24 12:19:42] = Boo!                                             =
#> FATAL [2026-08-24 12:19:42] ====================================================
log_layout(layout_blank)
log_with_separator("Boo!", level = FATAL)
#> ================================================================================
#> = Boo!                                                                         =
#> ================================================================================
logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
log_layout(logger)
log_with_separator("Boo!", level = FATAL, width = 120)
#> runnervm76f27/8754/global/eval 2026-08-24 12:19:42.373327 FATAL: =======================================================
#> runnervm76f27/8754/global/log_with_separator 2026-08-24 12:19:42.374208 FATAL: = Boo!                                                 =
#> runnervm76f27/8754/global/eval 2026-08-24 12:19:42.375592 FATAL: ========================================================
```
