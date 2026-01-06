# Check if R package can be loaded and fails loudly otherwise

Check if R package can be loaded and fails loudly otherwise

## Usage

``` r
fail_on_missing_package(pkg, min_version, call = NULL)
```

## Arguments

- pkg:

  string

- min_version:

  optional minimum version needed

- call:

  Call to include in error message.

## Examples

``` r
f <- function() fail_on_missing_package("foobar")
try(f())
#> Error : Please install the 'foobar' package to use pkgdown::build_site_github_pages
g <- function() fail_on_missing_package("stats")
g()
```
