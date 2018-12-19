# logger

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
 ![CRAN](https://www.r-pkg.org/badges/version/logger) [![Build Status](https://travis-ci.org/daroczig/logger.svg?branch=master)](https://travis-ci.org/daroczig/logger) [![Code Coverage](https://codecov.io/gh/daroczig/logger/branch/master/graph/badge.svg)](https://codecov.io/gh/daroczig/logger)

A lightweight, modern and flexibly logging utility for R -- heavily inspired by the `futile.logger` R package and `logging` Python module.

## Installation

`logger` is not on CRAN yet, please install from GitHub:

```r
remotes::install_github('daroczig/logger')
```

## Quick example

Setting the log level threshold to something low and logging various messages in ad-hoc and programmatic ways:

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

Setting a custom log layout to render the log records with colors:

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

But you could set up any custom colors and layout, eg using custom colors only for the log levels, make it grayscale, include the calling function or R package namespace with specific colors etc. For more details, see the related vignettes.

## Why yet another logging R package?

Although there are multiple pretty good options already hosted on CRAN when it comes to logging in R, such as

- [`futile.logger`](https://cran.r-project.org/package=futile.logger): probably the most popular `log4j` variant (and I'm a big fan)
- [`logging`](https://cran.r-project.org/package=logging): just like Python's `logging` package
- [`loggit`](https://cran.r-project.org/package=loggit): capture `message`, `warning` and `stop` function messages in a JSON file
- [`log4r`](https://cran.r-project.org/package=log4r): `log4j`-based, object-oriented logger
- [`rsyslog`](https://cran.r-project.org/package=rsyslog): logging to `syslog` on 'POSIX'-compatible operating systems
- [`lumberjack`](https://cran.r-project.org/package=lumberjack): provides a special operator to log changes in data

Also many more work-in-progress R packages hosted on eg GitHub, such as 

- https://github.com/smbache/loggr
- https://github.com/nfultz/tron
- https://github.com/metrumresearchgroup/logrrr
- https://github.com/lorenzwalthert/drogger
- https://github.com/s-fleck/yog

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

Welcome to the [Bazaar](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar), and if you have happened to already use any of the above mentioned R packages for logging, you might find useful the [Migration Guide](https://daroczig.github.io/logger/articles/migration.html).

## Interested in more details?

Check out the main documentation site at https://daroczig.github.io/logger or the vignettes on the below topics:

* [Introduction to logger](https://daroczig.github.io/logger/articles/Intro.html)
* [The Anatomy of a Log Request](https://daroczig.github.io/logger/articles/anatomy.html)
* [Customizing the Format and the Destination of a Log Record](https://daroczig.github.io/logger/articles/customize_logger.html)
* [Writing Custom Logger Extensions](https://daroczig.github.io/logger/articles/write_custom_extensions.html)
* [Migration Guide from other logging packages](https://daroczig.github.io/logger/articles/migration.html)
* [Logging from R Packages](https://daroczig.github.io/logger/articles/r_packages.html)
* [Simple Benchmarks on Performance](https://daroczig.github.io/logger/articles/performance.html)
