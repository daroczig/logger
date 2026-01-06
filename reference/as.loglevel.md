# Convert R object into a logger log-level

Convert R object into a logger log-level

## Usage

``` r
as.loglevel(x)
```

## Arguments

- x:

  string or integer

## Value

pander log-level, e.g. `INFO`

## Examples

``` r
as.loglevel(INFO)
#> Log level: INFO
as.loglevel(400L)
#> Log level: INFO
as.loglevel(400)
#> Log level: INFO
```
