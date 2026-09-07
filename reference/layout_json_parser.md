# Generate log layout function rendering JSON after merging meta fields with parsed list from JSON message

Generate log layout function rendering JSON after merging meta fields
with parsed list from JSON message

## Usage

``` r
layout_json_parser(fields = default_fields())
```

## Arguments

- fields:

  character vector of field names to be included in the JSON. If named,
  the names will be used as field names in the JSON.

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
[`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md),
[`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md),
[`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)

## Examples

``` r
log_formatter(formatter_json)
log_info(everything = 42)
#> INFO [2026-09-07 21:10:46] {"everything":42}

log_layout(layout_json_parser())
log_info(everything = 42)
#> {"time":"2026-09-07 21:10:46","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmejwal","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1022-azure","os_version":"#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026","pid":8563,"user":"runner","everything":42}

log_layout(layout_json_parser(fields = c("time", "node")))
log_info(cars = row.names(mtcars), species = unique(iris$Species))
#> {"time":"2026-09-07 21:10:46","node":"runnervmejwal","cars":["Mazda RX4","Mazda RX4 Wag","Datsun 710","Hornet 4 Drive","Hornet Sportabout","Valiant","Duster 360","Merc 240D","Merc 230","Merc 280","Merc 280C","Merc 450SE","Merc 450SL","Merc 450SLC","Cadillac Fleetwood","Lincoln Continental","Chrysler Imperial","Fiat 128","Honda Civic","Toyota Corolla","Toyota Corona","Dodge Challenger","AMC Javelin","Camaro Z28","Pontiac Firebird","Fiat X1-9","Porsche 914-2","Lotus Europa","Ford Pantera L","Ferrari Dino","Maserati Bora","Volvo 142E"],"species":["setosa","versicolor","virginica"]}

log_layout(layout_json_parser(fields = c(timestamp = "time", "node")))
log_info(
  message = paste(
    "Compared to the previous example,
    the 'time' field is renamed to 'timestamp'"
  )
)
#> {"timestamp":"2026-09-07 21:10:46","node":"runnervmejwal","message":"Compared to the previous example,\n    the 'time' field is renamed to 'timestamp'"}
```
