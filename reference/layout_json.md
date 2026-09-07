# Generate log layout function rendering JSON

Generate log layout function rendering JSON

## Usage

``` r
layout_json(fields = default_fields())
```

## Arguments

- fields:

  character vector of field names to be included in the JSON

## Value

character vector

## Note

This functionality depends on the jsonlite package.

## See also

Other log_layouts:
[`get_logger_meta_variables()`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md),
[`layout_blank()`](https://daroczig.github.io/logger/reference/layout_blank.md),
[`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md),
[`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md),
[`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
[`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md),
[`layout_json_parser()`](https://daroczig.github.io/logger/reference/layout_json_parser.md),
[`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md),
[`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)

## Examples

``` r
log_layout(layout_json())
log_info(42)
#> {"time":"2026-09-07 21:10:46","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmejwal","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8563,"user":"runner","msg":"42"}
log_info("ok {1:3} + {1:3} = {2*(1:3)}")
#> {"time":"2026-09-07 21:10:46","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmejwal","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8563,"user":"runner","msg":"ok 1 + 1 = 2"}
#> {"time":"2026-09-07 21:10:46","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmejwal","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8563,"user":"runner","msg":"ok 2 + 2 = 4"}
#> {"time":"2026-09-07 21:10:46","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmejwal","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8563,"user":"runner","msg":"ok 3 + 3 = 6"}
```
