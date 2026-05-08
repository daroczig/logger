# Try to evaluate an expressions and evaluate another expression on exception

Try to evaluate an expressions and evaluate another expression on
exception

## Usage

``` r
try %except% except
```

## Arguments

- try:

  R expression

- except:

  fallback R expression to be evaluated if `try` fails

## Note

Suppress log messages in the `except` namespace if you don't want to
throw a `WARN` log message on the exception branch.

## Examples

``` r
everything %except% 42
#> WARN [2026-05-08 20:47:23] Running '42' as 'everything' failed: 'object 'everything' not found'
#> [1] 42
everything <- "640kb"
everything %except% 42
#> [1] "640kb"

FunDoesNotExist(1:10) %except% sum(1:10) / length(1:10)
#> WARN [2026-05-08 20:47:23] Running 'sum(1:10)' as 'FunDoesNotExist(1:10)' failed: 'could not find function "FunDoesNotExist"'
#> [1] 5.5
FunDoesNotExist(1:10) %except% (sum(1:10) / length(1:10))
#> WARN [2026-05-08 20:47:23] Running '(sum(1:10)/length(1:10))' as 'FunDoesNotExist(1:10)' failed: 'could not find function "FunDoesNotExist"'
#> [1] 5.5
FunDoesNotExist(1:10) %except% MEAN(1:10) %except% mean(1:10)
#> WARN [2026-05-08 20:47:23] Running 'MEAN(1:10)' as 'FunDoesNotExist(1:10)' failed: 'could not find function "FunDoesNotExist"'
#> WARN [2026-05-08 20:47:23] Running 'mean(1:10)' as 'FunDoesNotExist(1:10) %except% MEAN(1:10)' failed: 'could not find function "MEAN"'
#> [1] 5.5
FunDoesNotExist(1:10) %except% (MEAN(1:10) %except% mean(1:10))
#> WARN [2026-05-08 20:47:23] Running '(MEAN(1:10) %except% mean(1:10))' as 'FunDoesNotExist(1:10)' failed: 'could not find function "FunDoesNotExist"'
#> WARN [2026-05-08 20:47:23] Running 'mean(1:10)' as 'MEAN(1:10)' failed: 'could not find function "MEAN"'
#> [1] 5.5
```
