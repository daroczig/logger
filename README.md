
<!-- README.md is generated from README.Rmd. Please edit that file -->

# logger <a href="https://daroczig.github.io/logger/"><img src="man/figures/logo.png" align="right" height="138" alt="logger website" /></a>

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN](https://www.r-pkg.org/badges/version/logger)](https://cran.r-project.org/package=logger)
[![Build
Status](https://github.com/daroczig/logger/workflows/R-CMD-check/badge.svg)](https://github.com/daroczig/logger/actions)
[![Code
Coverage](https://codecov.io/gh/daroczig/logger/branch/master/graph/badge.svg)](https://app.codecov.io/gh/daroczig/logger)
[![A Mikata
Project](https://mikata.dev/img/badge.svg)](https://mikata.dev)
<!-- badges: end -->

A lightweight, modern and flexible logging utility for R – heavily
inspired by the `futile.logger` R package and `logging` Python module.

## Installation

[![CRAN
version](https://www.r-pkg.org/badges/version-ago/logger)](https://cran.r-project.org/package=logger)

``` r
install.packages("logger")
```

The most recent, development version of `logger` can also be installed
from GitHub:

``` r
# install.packages("pak")
pak::pak("daroczig/logger")
```

## Quick example

Setting the log level threshold to something low and logging various
messages in ad-hoc and programmatic ways:

``` r
library(logger)
log_threshold(DEBUG)
log_info("Script starting up...")
#> INFO [2024-08-23 12:48:18] Script starting up...

pkgs <- available.packages()
log_info("There are {nrow(pkgs)} R packages hosted on CRAN!")
#> INFO [2024-08-23 12:48:19] There are 21137 R packages hosted on CRAN!

for (letter in letters) {
  lpkgs <- sum(grepl(letter, pkgs[, "Package"], ignore.case = TRUE))
  log_level(
    if (lpkgs < 5000) TRACE else DEBUG,
    "{lpkgs} R packages including the {shQuote(letter)} letter"
  )
}
#> DEBUG [2024-08-23 12:48:19] 10185 R packages including the 'a' letter
#> DEBUG [2024-08-23 12:48:19] 7016 R packages including the 'c' letter
#> DEBUG [2024-08-23 12:48:19] 5757 R packages including the 'd' letter
#> DEBUG [2024-08-23 12:48:19] 10907 R packages including the 'e' letter
#> DEBUG [2024-08-23 12:48:19] 8832 R packages including the 'i' letter
#> DEBUG [2024-08-23 12:48:19] 7065 R packages including the 'l' letter
#> DEBUG [2024-08-23 12:48:19] 7061 R packages including the 'm' letter
#> DEBUG [2024-08-23 12:48:19] 6673 R packages including the 'n' letter
#> DEBUG [2024-08-23 12:48:19] 7867 R packages including the 'o' letter
#> DEBUG [2024-08-23 12:48:19] 6582 R packages including the 'p' letter
#> DEBUG [2024-08-23 12:48:19] 11229 R packages including the 'r' letter
#> DEBUG [2024-08-23 12:48:19] 10296 R packages including the 's' letter
#> DEBUG [2024-08-23 12:48:19] 9525 R packages including the 't' letter

log_warn("There might be many, like {1:2} or more warnings!!!")
#> WARN [2024-08-23 12:48:19] There might be many, like 1 or more warnings!!!
#> WARN [2024-08-23 12:48:19] There might be many, like 2 or more warnings!!!
```

You can even use a custom log layout to render the log records with
colors, as you can see in `layout_glue_colors()`:

<img src="man/figures/colors.png" alt="colored log output">

But you could set up any custom colors and layout, eg using custom
colors only for the log levels, make it grayscale, include the calling
function or R package namespace with specific colors etc. For more
details, see `vignette("write_custom_extensions")`.

## Related work

There are many other logging packages available on CRAN:

- [`futile.logger`](https://cran.r-project.org/package=futile.logger):
  probably the most popular `log4j` variant (and I’m a big fan)
- [`logging`](https://cran.r-project.org/package=logging): just like
  Python’s `logging` package
- [`lgr`](https://cran.r-project.org/package=lgr): built on top of R6.
- [`loggit`](https://cran.r-project.org/package=loggit): capture
  `message`, `warning` and `stop` function messages in a JSON file
- [`log4r`](https://cran.r-project.org/package=log4r): `log4j`-based,
  object-oriented logger
- [`rsyslog`](https://cran.r-project.org/package=rsyslog): logging to
  `syslog` on ‘POSIX’-compatible operating systems
- [`lumberjack`](https://cran.r-project.org/package=lumberjack):
  provides a special operator to log changes in data

Why use logger? I decided to write the `n+1`th extensible `log4j` logger
that fits my liking — and hopefully yours as well — with the aim to:

- Keep it close to `log4j`.
- Respect the modern function/variable naming conventions and general R
  coding style.
- By default, rely on `glue()` when it comes to formatting / rendering
  log messages, but keep it flexible if others prefer `sprintf()`
  (e.g. for performance reasons) or other functions.
- Support vectorization (eg passing a vector to be logged on multiple
  lines).
- Make it easy to extend with new features (e.g. custom layouts, message
  formats and output).
- Prepare for writing to various services, streams etc
- Provide support for namespaces, preferably automatically finding and
  creating a custom namespace for all R packages writing log messages,
  each with optionally configurable log level threshold, message and
  output formats.
- Allow stacking loggers to implement logger hierarchy – even within a
  namespace, so that the very same `log` call can write all the `TRACE`
  log messages to the console, while only pushing `ERROR`s to DataDog
  and eg `INFO` messages to CloudWatch.
- Optionally colorize log message based on the log level.
- Make logging fun!

Welcome to the
[Bazaar](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar)! If
you already use any of the above packages for logging, you might find
`vignette("migration")` useful.

## Interested in more details?

<div class=".pkgdown-hide">

Check out the main documentation site at
<https://daroczig.github.io/logger/> or the vignettes on the below
topics:

- Introduction to logger: `vignette("logger")`.
- Customizing the Format and the Destination of a Log Record:
  `vignette("customize_logger")`
- Writing Custom Logger Extensions:
  `vignette("write_custom_extensions")`
- Migration Guide from other logging packages: `vignette("migration")`
- Logging from R Packages: `vignette("r_packages")`
- Simple Benchmarks on Performance: `vignette("performance")`

</div>

If you prefer visual content, you can watch the video recording of the
“Getting things logged” talk at RStudio::conf(2020):

[![Gergely Daroczi presenting “Getting things logged” on using the
`logger` R package at the RStudio conference in
2020](https://img.youtube.com/vi/_rUuBbml9dU/0.jpg)](https://www.youtube.com/watch?v=_rUuBbml9dU)
