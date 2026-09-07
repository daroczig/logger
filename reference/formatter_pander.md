# Formats R objects with pander

Formats R objects with pander

## Usage

``` r
formatter_pander(
  x,
  ...,
  .logcall = sys.call(),
  .topcall = sys.call(-1),
  .topenv = parent.frame()
)
```

## Arguments

- x:

  object to be logged

- ...:

  optional parameters passed to `pander`

- .logcall:

  the logging call being evaluated (useful in formatters and layouts
  when you want to have access to the raw, unevaluated R expression)

- .topcall:

  R expression from which the logging function was called (useful in
  formatters and layouts to extract the calling function's name or
  arguments)

- .topenv:

  original frame of the `.topcall` calling function where the formatter
  function will be evaluated and that is used to look up the `namespace`
  as well via `logger:::top_env_name`

## Value

character vector

## Note

This functionality depends on the pander package.

## See also

Other log_formatters:
[`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md),
[`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md),
[`formatter_glue_or_sprintf()`](https://daroczig.github.io/logger/reference/formatter_glue_or_sprintf.md),
[`formatter_glue_safe()`](https://daroczig.github.io/logger/reference/formatter_glue_safe.md),
[`formatter_json()`](https://daroczig.github.io/logger/reference/formatter_json.md),
[`formatter_logging()`](https://daroczig.github.io/logger/reference/formatter_logging.md),
[`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md),
[`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)

## Examples

``` r
log_formatter(formatter_pander)
log_info("42")
#> INFO [2026-09-07 21:10:44] 42
log_info(42)
#> INFO [2026-09-07 21:10:44] _42_
log_info(4 + 2)
#> INFO [2026-09-07 21:10:44] _6_
log_info(head(iris))
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44] -------------------------------------------------------------------
#> INFO [2026-09-07 21:10:44]  Sepal.Length   Sepal.Width   Petal.Length   Petal.Width   Species 
#> INFO [2026-09-07 21:10:44] -------------- ------------- -------------- ------------- ---------
#> INFO [2026-09-07 21:10:44]      5.1            3.5           1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]      4.9             3            1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]      4.7            3.2           1.3            0.2       setosa  
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]      4.6            3.1           1.5            0.2       setosa  
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]       5             3.6           1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]      5.4            3.9           1.7            0.4       setosa  
#> INFO [2026-09-07 21:10:44] -------------------------------------------------------------------
#> INFO [2026-09-07 21:10:44] 
log_info(head(iris), style = "simple")
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]  Sepal.Length   Sepal.Width   Petal.Length   Petal.Width   Species 
#> INFO [2026-09-07 21:10:44] -------------- ------------- -------------- ------------- ---------
#> INFO [2026-09-07 21:10:44]      5.1            3.5           1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44]      4.9             3            1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44]      4.7            3.2           1.3            0.2       setosa  
#> INFO [2026-09-07 21:10:44]      4.6            3.1           1.5            0.2       setosa  
#> INFO [2026-09-07 21:10:44]       5             3.6           1.4            0.2       setosa  
#> INFO [2026-09-07 21:10:44]      5.4            3.9           1.7            0.4       setosa  
#> INFO [2026-09-07 21:10:44] 
log_info(lm(hp ~ wt, mtcars))
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44] ----------------------------------------------------------------
#> INFO [2026-09-07 21:10:44]      &nbsp;        Estimate   Std. Error   t value    Pr(>|t|)  
#> INFO [2026-09-07 21:10:44] ----------------- ---------- ------------ ---------- -----------
#> INFO [2026-09-07 21:10:44]  **(Intercept)**    -1.821      32.32      -0.05633    0.9555   
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44]      **wt**         46.16       9.625       4.796     4.146e-05 
#> INFO [2026-09-07 21:10:44] ----------------------------------------------------------------
#> INFO [2026-09-07 21:10:44] 
#> INFO [2026-09-07 21:10:44] Table: Fitting linear model: hp ~ wt
#> INFO [2026-09-07 21:10:44] 
```
