# Injects a logger call to standard messages

This function sets a hook to trigger
[`log_info()`](https://daroczig.github.io/logger/reference/log_level.md)
when `message` is called to log the informative messages with the global
`logger` layout and appender.

## Usage

``` r
log_messages()
```

## Examples

``` r
if (FALSE) { # \dontrun{
log_messages()
message("hi there")
} # }
```
