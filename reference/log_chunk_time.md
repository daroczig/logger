# Automatically log execution time of knitr chunks

Calling this function in the first chunk of a document will instruct
knitr to automatically log the execution time of each chunk. If using
[`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md)
or
[`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md)
then the `options` variable will be available, providing the chunk
options such as chunk label etc.

## Usage

``` r
log_chunk_time(..., level = INFO, namespace = NA_character_)
```

## Arguments

- ...:

  passed to
  [`log_level()`](https://daroczig.github.io/logger/reference/log_level.md)

- level:

  see
  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- namespace:

  x

## Examples

``` r
# To be put in the first chunk of a document
log_chunk_time("chunk {options$label}")
```
