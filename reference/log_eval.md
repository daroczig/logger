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
#> INFO [2026-01-06 21:43:06] 'pi * 2' => '6.28318530717959'
#> [1] 6.283185

## lowering the log level threshold so that we don't have to set a higher level in log_eval
log_threshold(TRACE)
log_eval(x <- 4)
#> TRACE [2026-01-06 21:43:06] 'x <- 4' => '4'
log_eval(sqrt(x))
#> TRACE [2026-01-06 21:43:06] 'sqrt(x)' => '2'
#> [1] 2

## log_eval can be called in-line as well as returning the return value of the expression
x <- log_eval(mean(runif(1e3)))
#> TRACE [2026-01-06 21:43:06] 'mean(runif(1000))' => '0.509379567583324'
x
#> [1] 0.5093796

## https://twitter.com/krlmlr/status/1067864829547999232
f <- sqrt
g <- mean
x <- 1:31
log_eval(f(g(x)), level = INFO)
#> INFO [2026-01-06 21:43:06] 'f(g(x))' => '4'
#> [1] 4
log_eval(y <- f(g(x)), level = INFO)
#> INFO [2026-01-06 21:43:06] 'y <- f(g(x))' => '4'

## returning a function
log_eval(f <- sqrt)
#> TRACE [2026-01-06 21:43:06] 'f <- sqrt' => '.Primitive("sqrt")'
log_eval(f)
#> TRACE [2026-01-06 21:43:06] 'f' => '.Primitive("sqrt")'
#> function (x)  .Primitive("sqrt")

## evaluating something returning a wall of "text"
log_eval(f <- log_eval)
#> TRACE [2026-01-06 21:43:06] 'f <- log_eval' => 'function (expr, level = TRACE, multiline = FALSE)  {     expr <- substitute(expr)     exprs <- gsub("\n", " ", deparse(expr), fixed = TRUE)     timer <- Sys.time()     res <- withVisible(eval.parent(expr))     if (multiline == FALSE) {         log_level(level, skip_formatter(paste(shQuote(paste(exprs,              collapse = " ")), "=>", shQuote(paste(gsub("\n",              " ", deparse(res$value)), collapse = " ")))))     }     else {         log_level(level, "Running expression: ====================")         log_level(level, skip_formatter(exprs))         log_level(level, "Results: ===============================")         log_level(level, skip_formatter(capture.output(res$value)))         log_level(level, paste("Elapsed time:", round(difftime(Sys.time(),              timer, units = "secs"), 2), "sec"))     }     if (res$visible == TRUE) {         res$value     }     else {         invisible(res$value)     } }'
log_eval(f <- log_eval, multiline = TRUE)
#> TRACE [2026-01-06 21:43:06] Running expression: ====================
#> TRACE [2026-01-06 21:43:06] f <- log_eval
#> TRACE [2026-01-06 21:43:06] Results: ===============================
#> TRACE [2026-01-06 21:43:06] function (expr, level = TRACE, multiline = FALSE) 
#> TRACE [2026-01-06 21:43:06] {
#> TRACE [2026-01-06 21:43:06]     expr <- substitute(expr)
#> TRACE [2026-01-06 21:43:06]     exprs <- gsub("\n", " ", deparse(expr), fixed = TRUE)
#> TRACE [2026-01-06 21:43:06]     timer <- Sys.time()
#> TRACE [2026-01-06 21:43:06]     res <- withVisible(eval.parent(expr))
#> TRACE [2026-01-06 21:43:06]     if (multiline == FALSE) {
#> TRACE [2026-01-06 21:43:06]         log_level(level, skip_formatter(paste(shQuote(paste(exprs, 
#> TRACE [2026-01-06 21:43:06]             collapse = " ")), "=>", shQuote(paste(gsub("\n", 
#> TRACE [2026-01-06 21:43:06]             " ", deparse(res$value)), collapse = " ")))))
#> TRACE [2026-01-06 21:43:06]     }
#> TRACE [2026-01-06 21:43:06]     else {
#> TRACE [2026-01-06 21:43:06]         log_level(level, "Running expression: ====================")
#> TRACE [2026-01-06 21:43:06]         log_level(level, skip_formatter(exprs))
#> TRACE [2026-01-06 21:43:06]         log_level(level, "Results: ===============================")
#> TRACE [2026-01-06 21:43:06]         log_level(level, skip_formatter(capture.output(res$value)))
#> TRACE [2026-01-06 21:43:06]         log_level(level, paste("Elapsed time:", round(difftime(Sys.time(), 
#> TRACE [2026-01-06 21:43:06]             timer, units = "secs"), 2), "sec"))
#> TRACE [2026-01-06 21:43:06]     }
#> TRACE [2026-01-06 21:43:06]     if (res$visible == TRUE) {
#> TRACE [2026-01-06 21:43:06]         res$value
#> TRACE [2026-01-06 21:43:06]     }
#> TRACE [2026-01-06 21:43:06]     else {
#> TRACE [2026-01-06 21:43:06]         invisible(res$value)
#> TRACE [2026-01-06 21:43:06]     }
#> TRACE [2026-01-06 21:43:06] }
#> TRACE [2026-01-06 21:43:06] <bytecode: 0x55d7f8aba528>
#> TRACE [2026-01-06 21:43:06] <environment: namespace:logger>
#> TRACE [2026-01-06 21:43:06] Elapsed time: 0 sec

## doing something computationally intensive
log_eval(system.time(for (i in 1:100) mad(runif(1000))), multiline = TRUE)
#> TRACE [2026-01-06 21:43:07] Running expression: ====================
#> TRACE [2026-01-06 21:43:07] system.time(for (i in 1:100) mad(runif(1000)))
#> TRACE [2026-01-06 21:43:07] Results: ===============================
#> TRACE [2026-01-06 21:43:07]    user  system elapsed 
#> TRACE [2026-01-06 21:43:07]    0.01    0.00    0.01 
#> TRACE [2026-01-06 21:43:07] Elapsed time: 0.09 sec
#>    user  system elapsed 
#>    0.01    0.00    0.01 
```
