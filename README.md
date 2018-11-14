# logger

A logging utility heavily inspired by `futile.logger`, loosely based on `log4j`.

## Installation

`logger` is not on CRAN yet, please install from GitHub:

```r
devtools::install_github('daroczig/logger')
```

## Why another logging R package?

Although there are multiple very good options already hosted on CRAN when it comes to logging in R:

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

So based on all the above subjective opinions, decided to write the `n+1`th extensible `log4j` logger that fits my liking -- and hopefully yours as well -- with the focus being on:

- keep it close to `log4j`
- respect the most recent function / variable naming conventions and general R coding style
- rely on `glue` when it comes to formatting / rendering log messages
- make it easy to extend with new features (eg layouts, message formats and output)
- prepare for writing to various services
- provide support for namespaces, preferably automatically finding and creating a custom namespace for all R packages writing log messages -- each with optionally configurable log level threshold, message and output formats
- optionally colorize log message based on the log level
- make logging fun

