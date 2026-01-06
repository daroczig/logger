# Deparse and join all lines into a single line

Calling `deparse` and joining all the returned lines into a single line,
separated by whitespace, and then cleaning up all the duplicated
whitespace (except for excessive whitespace in strings between single or
double quotes).

## Usage

``` r
deparse_to_one_line(x)
```

## Arguments

- x:

  object to `deparse`

## Value

string
