# Evaluate an expression and log results

Evaluate an expression and log results

## Usage

``` r
log_eval(expr, level = TRACE, multiline = FALSE)
```

## Arguments

- expr:

  R expression to be evaluated while logging the expression itself along
  with the result

- level:

  [`log_levels()`](https://daroczig.github.io/logger/reference/log_levels.md)

- multiline:

  setting to `FALSE` will print both the expression (enforced to be on
  one line by removing line-breaks if any) and its result on a single
  line separated by `=>`, while setting to `TRUE` will log the
  expression and the result in separate sections reserving line-breaks
  and rendering the printed results

## Examples

``` r
log_eval(pi * 2, level = INFO)
#> INFO [2026-05-08 20:47:27] 'pi * 2' => '6.28318530717959'
#> [1] 6.283185

## lowering the log level threshold so that we don't have to set a higher level in log_eval
log_threshold(TRACE)
log_eval(x <- 4)
#> TRACE [2026-05-08 20:47:27] 'x <- 4' => '4'
log_eval(sqrt(x))
#> TRACE [2026-05-08 20:47:27] 'sqrt(x)' => '2'
#> [1] 2

## log_eval can be called in-line as well as returning the return value of the expression
x <- log_eval(mean(runif(1e3)))
#> TRACE [2026-05-08 20:47:27] 'mean(runif(1000))' => '0.506193717753049'
x
#> [1] 0.5061937

## https://twitter.com/krlmlr/status/1067864829547999232
f <- sqrt
g <- mean
x <- 1:31
log_eval(f(g(x)), level = INFO)
#> INFO [2026-05-08 20:47:27] 'f(g(x))' => '4'
#> [1] 4
log_eval(y <- f(g(x)), level = INFO)
#> INFO [2026-05-08 20:47:27] 'y <- f(g(x))' => '4'

## returning a function
log_eval(f <- sqrt)
#> TRACE [2026-05-08 20:47:27] 'f <- sqrt' => '.Primitive("sqrt")'
log_eval(f)
#> TRACE [2026-05-08 20:47:27] 'f' => '.Primitive("sqrt")'
#> function (x)  .Primitive("sqrt")

## evaluating something returning a wall of "text"
log_eval(f <- log_eval)
#> TRACE [2026-05-08 20:47:27] 'f <- log_eval' => 'function (expr, level = TRACE, multiline = FALSE)  {     expr <- substitute(expr)     exprs <- gsub("\n", " ", deparse(expr), fixed = TRUE)     timer <- Sys.time()     res <- withVisible(eval.parent(expr))     if (multiline == FALSE) {         log_level(level, skip_formatter(paste(shQuote(paste(exprs,              collapse = " ")), "=>", shQuote(paste(gsub("\n",              " ", deparse(res$value)), collapse = " ")))))     }     else {         log_level(level, "Running expression: ====================")         log_level(level, skip_formatter(exprs))         log_level(level, "Results: ===============================")         log_level(level, skip_formatter(capture.output(res$value)))         log_level(level, paste("Elapsed time:", round(difftime(Sys.time(),              timer, units = "secs"), 2), "sec"))     }     if (res$visible == TRUE) {         res$value     }     else {         invisible(res$value)     } }'
log_eval(f <- log_eval, multiline = TRUE)
#> TRACE [2026-05-08 20:47:27] Running expression: ====================
#> TRACE [2026-05-08 20:47:27] f <- log_eval
#> TRACE [2026-05-08 20:47:27] Results: ===============================
#> TRACE [2026-05-08 20:47:27] function (expr, level = TRACE, multiline = FALSE) 
#> TRACE [2026-05-08 20:47:27] {
#> TRACE [2026-05-08 20:47:27]     expr <- substitute(expr)
#> TRACE [2026-05-08 20:47:27]     exprs <- gsub("\n", " ", deparse(expr), fixed = TRUE)
#> TRACE [2026-05-08 20:47:27]     timer <- Sys.time()
#> TRACE [2026-05-08 20:47:27]     res <- withVisible(eval.parent(expr))
#> TRACE [2026-05-08 20:47:27]     if (multiline == FALSE) {
#> TRACE [2026-05-08 20:47:27]         log_level(level, skip_formatter(paste(shQuote(paste(exprs, 
#> TRACE [2026-05-08 20:47:27]             collapse = " ")), "=>", shQuote(paste(gsub("\n", 
#> TRACE [2026-05-08 20:47:27]             " ", deparse(res$value)), collapse = " ")))))
#> TRACE [2026-05-08 20:47:27]     }
#> TRACE [2026-05-08 20:47:27]     else {
#> TRACE [2026-05-08 20:47:27]         log_level(level, "Running expression: ====================")
#> TRACE [2026-05-08 20:47:27]         log_level(level, skip_formatter(exprs))
#> TRACE [2026-05-08 20:47:27]         log_level(level, "Results: ===============================")
#> TRACE [2026-05-08 20:47:27]         log_level(level, skip_formatter(capture.output(res$value)))
#> TRACE [2026-05-08 20:47:27]         log_level(level, paste("Elapsed time:", round(difftime(Sys.time(), 
#> TRACE [2026-05-08 20:47:27]             timer, units = "secs"), 2), "sec"))
#> TRACE [2026-05-08 20:47:27]     }
#> TRACE [2026-05-08 20:47:27]     if (res$visible == TRUE) {
#> TRACE [2026-05-08 20:47:27]         res$value
#> TRACE [2026-05-08 20:47:27]     }
#> TRACE [2026-05-08 20:47:27]     else {
#> TRACE [2026-05-08 20:47:27]         invisible(res$value)
#> TRACE [2026-05-08 20:47:27]     }
#> TRACE [2026-05-08 20:47:27] }
#> TRACE [2026-05-08 20:47:27] <bytecode: 0x55d2999c4c00>
#> TRACE [2026-05-08 20:47:27] <environment: namespace:logger>
#> TRACE [2026-05-08 20:47:27] Elapsed time: 0 sec

## doing something computationally intensive
log_eval(system.time(for (i in 1:100) mad(runif(1000))), multiline = TRUE)
#> TRACE [2026-05-08 20:47:27] Running expression: ====================
#> TRACE [2026-05-08 20:47:27] system.time(for (i in 1:100) mad(runif(1000)))
#> TRACE [2026-05-08 20:47:27] Results: ===============================
#> TRACE [2026-05-08 20:47:27]    user  system elapsed 
#> TRACE [2026-05-08 20:47:27]    0.01    0.00    0.01 
#> TRACE [2026-05-08 20:47:27] Elapsed time: 0.12 sec
#>    user  system elapsed 
#>    0.01    0.00    0.01 
```
