# Generate log layout function using common variables available via glue syntax

`format` is passed to
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) with
access to the below variables:

- msg: the actual log message

- further variables set by
  [`get_logger_meta_variables()`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md)

## Usage

``` r
layout_glue_generator(
  format = "{level} [{format(time, \"%Y-%m-%d %H:%M:%S\")}] {msg}"
)
```

## Arguments

- format:

  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)-flavored
  layout of the message using the above variables

## Value

function taking `level` and `msg` arguments - keeping the original call
creating the generator in the `generator` attribute that is returned
when calling
[`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md)
for the currently used layout

## See also

See example calls from
[`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md)
and
[`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md).

Other log_layouts:
[`get_logger_meta_variables()`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md),
[`layout_blank()`](https://daroczig.github.io/logger/reference/layout_blank.md),
[`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md),
[`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md),
[`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
[`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md),
[`layout_json_parser()`](https://daroczig.github.io/logger/reference/layout_json_parser.md),
[`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md),
[`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)

## Examples

``` r
example_layout <- layout_glue_generator(
  format = "{node}/{pid}/{ns}/{ans}/{topenv}/{fn} {time} {level}: {msg}"
)
example_layout(INFO, "try {runif(1)}")
#> runnervmeorf1/9021/NA/global/R_GlobalEnv/eval 2026-05-08 20:47:24.547137 INFO: try {runif(1)}

log_layout(example_layout)
log_info("try {runif(1)}")
#> runnervmeorf1/9021/global/global/R_GlobalEnv/eval 2026-05-08 20:47:24.549617 INFO: try 0.0807501375675201
```
