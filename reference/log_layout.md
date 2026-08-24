# Get or set log record layout

Get or set log record layout

## Usage

``` r
log_layout(layout = NULL, namespace = "global", index = 1)
```

## Arguments

- layout:

  function defining the structure of a log record, eg
  [`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md),
  [`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md)
  or
  [`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
  [`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md),
  or generator functions such as
  [`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md),
  default NULL

- namespace:

  logger namespace

- index:

  index of the logger within the namespace

## See also

Other log configutation functions:
[`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md),
[`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md),
[`log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.md)

## Examples

``` r
log_layout(layout_json())
log_info(42)
#> {"time":"2026-08-24 12:19:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervm76f27","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8754,"user":"runner","msg":"42"}
```
