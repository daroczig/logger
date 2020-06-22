# logger

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) ![CRAN](https://www.r-pkg.org/badges/version/logger) [![Build Status](https://travis-ci.org/daroczig/logger.svg?branch=master)](https://travis-ci.org/daroczig/logger) [![Code Coverage](https://codecov.io/gh/daroczig/logger/branch/master/graph/badge.svg)](https://codecov.io/gh/daroczig/logger) [![A Mikata Project](https://img.shields.io/badge/Mikata-Project-blue?style=flat&logo=data:image/png;base64,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&color=49a4db)](https://mikata.dev)

A lightweight, modern and flexibly logging utility for R -- heavily inspired by the `futile.logger` R package and `logging` Python module.

## Installation

![CRAN version](http://www.r-pkg.org/badges/version-ago/logger)

```r
install.packages('logger')
```

The most recent, development version of `logger` can also be installed from GitHub:

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
