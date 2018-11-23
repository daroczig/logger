# logger

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
 ![CRAN](https://www.r-pkg.org/badges/version/logger) [![Build Status](https://travis-ci.org/daroczig/logger.svg?branch=master)](https://travis-ci.org/daroczig/logger) [![Code Coverage](https://codecov.io/gh/daroczig/logger/branch/master/graph/badge.svg)](https://codecov.io/gh/daroczig/logger)

A modern and flexibly logging utility for R -- heavily inspired by the `futile.logger` R package and `logging` Python module.

## Installation

`logger` is not on CRAN yet, please install from GitHub:

```r
devtools::install_github('daroczig/logger')
```

## Quick example

Setting the log level threshold and logging various messages in ad-hoc and programmatic ways:

```r
library(logger)
log_threshold(DEBUG)
log_info('Script starting up...')
#> INFO [2018-20-11 22:49:36] Script starting up...

pkgs <- available.packages()
log_info('There are {nrow(pkgs)} R packages hosted on CRAN!')
#> INFO [2018-20-11 22:49:37] There are 13433 R packages hosted on CRAN!

for (letter in letters) {
    lpkgs <- sum(grepl(letter, pkgs[, 'Package'], ignore.case = TRUE))
    log_level(if (lpkgs < 5000) TRACE else DEBUG,
              '{lpkgs} R packages including the {shQuote(letter)} letter')
}
#> DEBUG [2018-20-11 22:49:38] 6300 R packages including the 'a' letter
#> DEBUG [2018-20-11 22:49:38] 6772 R packages including the 'e' letter
#> DEBUG [2018-20-11 22:49:38] 5412 R packages including the 'i' letter
#> DEBUG [2018-20-11 22:49:38] 7014 R packages including the 'r' letter
#> DEBUG [2018-20-11 22:49:38] 6402 R packages including the 's' letter
#> DEBUG [2018-20-11 22:49:38] 5864 R packages including the 't' letter

log_warn('There might be many, like {1:2} or more warnings!!!')
#> WARN [2018-20-11 22:49:39] There might be many, like 1 or more warnings!!!
#> WARN [2018-20-11 22:49:39] There might be many, like 2 or more warnings!!!
```

Setting custom layout to render the log records with colors:

```r
library(logger)
log_layout(layout_glue_colors)
log_threshold(TRACE)
log_info('Starting the script...')
log_debug('This is the second log line')
log_trace('Note that the 2nd line is being placed right after the 1st one.')
log_success('Doing pretty well so far!')
log_warn('But beware, as some errors might come :/')
log_error('This is a problem')
log_debug('Note that getting an error is usually bad')
log_error('This is another problem')
log_fatal('The last problem')
```

Or simply run the related demo:

```r
demo(colors, package = 'logger', echo = FALSE)
```

<img src="man/figures/colors.png" alt="colored log output">

But you could set up any custom colors and layout, eg using custom colors only for the log levels, make it grayscale, include the calling function or R package namespace with specific colors etc.

## Why another logging R package?

Although there are multiple pretty good options already hosted on CRAN when it comes to logging in R, such as

- `futile.logger`: probably the most popular `log4j` variant (and I'm a big fan)
- `logging`: just like Python's `logging` package
- `loggit`: capture `message`, `warning` and `stop` function messages in a JSON file
- `log4r`: `log4j`-based, object-oriented logger
- `rsyslog`: logging to `syslog` on 'POSIX'-compatible operating systems

But some/most of these packages are

- not actively maintained any more, and/or maintainers are not being open for new features / patches
- not being modular enough for extensions
- prone to scoping issues
- using strange syntax elements, eg dots in function names or object-oriented approaches not being very familiar to most R users
- requires a lot of typing and code repetitions

So based on all the above subjective opinions, I decided to write the `n+1`th extensible `log4j` logger that fits my liking -- and hopefully yours as well -- with the focus being on:

- keep it close to `log4j`
- respect the most recent function / variable naming conventions and general R coding style
- by default, rely on `glue` when it comes to formatting / rendering log messages, but keep it flexible if others prefer `sprintf` (eg for performance reasons) or other functions
- support vectorization (eg passing a vector to be logged on multiple lines)
- make it easy to extend with new features (eg custom layouts, message formats and output)
- prepare for writing to various services, streams etc
- provide support for namespaces, preferably automatically finding and creating a custom namespace for all R packages writing log messages, each with optionally configurable log level threshold, message and output formats
- allow stacking loggers to implement logger hierarchy -- even within a namespace, so that the very same `log` call can write all the `TRACE` log messages to the console, while only pushing `ERROR`s to DataDog and eg `INFO` messages to CloudWatch
- optionally colorize log message based on the log level
- make logging fun

Welcome to the Bazaar!

## The first steps with `logger`

TODO or in vignette?

## Interested in more details?

Check out the main documentation site at https://daroczig.github.io/logger or the vignettes on the below topics:

* [101](TODO)
* [The Anatomy of a Log Request](https://daroczig.github.io/logger/articles/logger_structure.html)
* [Customizing the format and destination of log records](https://daroczig.github.io/logger/articles/customize_logger.html)
* [Writing custom extensions](TODO)
* [Logging from R packages][TODO]





## Performance

Although this has not been an important feature in the early development and overall design of this logger implementation, but with the default `layout_simple` and `formatter_glue`, it seems to perform pretty well:

```r
library(microbenchmark)
library(futile.logger)
t1 <- tempfile()
flog.appender(appender.file(t1))
#> NULL
library(logger)
#> The following objects are masked from ‘package:futile.logger’: DEBUG, ERROR, FATAL, INFO, TRACE, WARN
t2 <- tempfile()
log_appender(appender_file(t2))
string1 <- function() flog.info('hi')
string2 <- function() log_info('hi')
dynamic1 <- function() flog.info('hi %s', 42)
dynamic2 <- function() log_info('hi {42}')
vector1 <- function() flog.info(paste('hi', 1:5))
vector2 <- function() log_info('hi {1:5}')
microbenchmark(string1(), string2(), vector1(), vector2(), dynamic1(), dynamic2(), times = 1e3)
#> Unit: microseconds
#>        expr      min        lq      mean    median       uq       max neval cld
#>   string1() 1510.372 1596.9630 1901.6076 1644.6540 1851.185  8995.092  1000   b
#>   string2()  331.924  363.5350  466.1253  391.1195  441.039 27085.823  1000  a 
#>   vector1() 1532.526 1609.0395 1889.2811 1669.5170 1865.571  6503.950  1000   b
#>   vector2()  399.974  432.0735  519.9258  463.9960  521.519  2574.311  1000  a 
#>  dynamic1() 1529.500 1615.7520 1949.9390 1668.8430 1888.323 29860.102  1000   b
#>  dynamic2()  379.412  413.6555  505.2265  439.7285  495.892  2699.117  1000  a 

paste(t1, length(readLines(t1)))
#> [1] "/tmp/Rtmp3Fp6qa/file7a8919485a36 7000"
paste(t2, length(readLines(t2)))
#> [1] "/tmp/Rtmp3Fp6qa/file7a89b17929f 7000"
```

On the other hand, there are some low-hanging fruits to improve performance, eg caching the `logger` function in the namespace, or using much faster message formatters (eg `paste0` or `sprintf` instead of `glue`) if needed.
