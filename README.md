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

## The structure of a logger and a log record

Minimum requirements of a `logger` and its required parameters to log something:

* logger definition:

    * log level `threshold`, eg `ERROR`, which defines the minimum log level required for actual logging
    * `formatter` function, which converts the R objects passed to the logger into an actual log message (to be then passed to the `layout` function), eg
    
        ```r
        formatter <- function(...) paste(..., collapse = ' ', sep = ' ')
        formatter(letters[1:3], 'foo', pi)
        #> [1] "a foo 3.14159265358979 b foo 3.14159265358979 c foo 3.14159265358979"
        ```

    * `layout` function, which defines the format of a log record, having access to some extra variables describing the calling environment of the log record (like timestamp, hostname, username, calling function etc), eg

        * a function returning structured text including log level, timestamp and message
        
            ```r
            layout <- function(level, msg) sprintf('%s [%s] %s', level, msg)
            layout(INFO, 'Happy Thursday!')
            #> INFO [1970-01-01 00:00:00] Happy Thursday!
            ```
        
        * a function returning a JSON object of log level, timestamp, hostname, calling function and message
        
            ```r
            layout <- function(level, msg) toJSON(level = level, timestamp = time, hostname = node, message = msg)
            layout(INFO, 'Happy Thursday!')
            #> {'level': 'INFO', 'timestamp': '1970-01-01 00:00:00', 'hostname': 'foobar', 'message': 'Happy Thursday!'}
            ```

    * `appender` function, which writes the actual log record somewhere, eg `stdout`, a file or a streaming service, eg
    
        ```r
        appender <- function(line) cat(line, '\n')
        appender('INFO [now] I am a log message')
        #> INFO [now] I am a log message 
        ```

* user-provided parameters: 

    * log level of the log record, eg `INFO`, which describes the severity of a message
    * R objects to be logged

Putting all these together (by explicitly setting the default config):

```r
log_threshold(INFO)
log_formatter(formatter_glue)
log_layout(layout_simple)
log_appender(appender_console)
log_debug('I am a low level log message')
log_warn('I am a higher level log message')
#> WARN [2018-22-11 11:35:48] I am a higher level log message
```

## Log levels

`logger` uses the default `log4j` log levels and supports suppressing log messages with lower level compared to the currently set threshold in the namespace:

```r
log_info('Hi, there!')
#> INFO [2018-14-11 02:04:31] Hi, there!
log_debug('How are you doing today?')
log_threshold()
#> Log level: INFO
log_threshold(TRACE)
log_debug('How are you doing today?')
#> DEBUG [2018-14-11 02:05:15] How are you doing today?
```

If you want to define the log level in a programmatic way, check out the `log_level` function, and see `?log_levels` for all the supported log levels.

## Log namespaces

By default, all log messages will be processed by the global logging function, but you may also use custom namespaces (eg to deliver specific log records to a special destination or to apply custom log level threshold) and even multiple loggers as well within the very same namespace (eg to deliver all `INFO` and above log levels in the console and everything below that to a trace log file). For examples on these, please see below.

## Log message formats

By default, the `log_level` and its derivative functions will simply record the log-level, current timestamp and the message after being processed by `glue`:

```r
log_info(42)
#> INFO [2018-14-11 02:11:10] 42
log_info('The answer is {42}')
#> INFO [2018-14-11 02:11:11] The answer is 42
log_info('The answers are {1:5}')
#> INFO [2018-14-11 02:17:09] The answers are 1
#> INFO [2018-14-11 02:17:09] The answers are 2
#> INFO [2018-14-11 02:17:09] The answers are 3
#> INFO [2018-14-11 02:17:09] The answers are 4
#> INFO [2018-14-11 02:17:09] The answers are 5
```

In the above example, first, `42` was converted to a string by a message formatter, then the message was passed to a layout function to generate the actual log record.

## Log layouts

An example of another layout function writing the same log messages in JSON:

```r
log_layout(layout_json)
log_info(42)
#> {"level":4,"timestamp":"2018-11-14 02:11:47","message":"42"}
log_info(1:3)
#> {"level":4,"timestamp":"2018-11-14 02:17:36","message":"1"}
#> {"level":4,"timestamp":"2018-11-14 02:17:36","message":"2"}
#> {"level":4,"timestamp":"2018-11-14 02:17:36","message":"3"}
```

To customize the format how the log messages are being rendered, see `?layout_glue_generator` that provides very easy access to a bunch variables -- quick examples on automatically logging the call from which the log message originated along with the (package) namespace, calling function's name, hostname, user running the R process etc:

* define custom logger:

    ```r
    logger <- layout_glue_generator(format = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
    log_layout(logger)
    ```

* check what's being logged when called from the global environment:

    ```r
    log_info('foo')
    #> nevermind/21133/R_GlobalEnv/NA 2018-14-11 01:31:51 INFO: foo
    ```

* check what's being logged when called from a custom function:

    ```r
    f <- function() log_info('foo')
    f()
    #> nevermind/21133/R_GlobalEnv/f 2018-14-11 01:32:46 INFO: foo
    ```

* check what's being logged when called from a package:

    ```r
    devtools::load_all(system.file('tests/logger-tester-package', package = 'logger'))
    #> Loading logger.tester
    logger_tester_function(INFO, 'hi from tester package')
    #> nevermind/21133/logger.tester/logger_tester_function 2018-14-11 01:32:56 INFO: hi from tester package
    ```

* suppress messages in a namespace:

    ```r
    log_threshold(namespace = 'logger.tester')
    #> Log level: INFO 
    log_threshold(WARN, namespace = 'logger.tester')
    logger_tester_function(INFO, 'hi from tester package')
    logger_tester_function(WARN, 'hi from tester package')
    #> nevermind/21133/logger.tester/logger_tester_function 2018-14-11 01:33:16 WARN: hi from tester package
    log_info('I am still working in the global namespace')
    #> nevermind/21133/R_GlobalEnv/NA 2018-14-11 01:33:21 INFO: I am still working in the global namespace
    ```

Note that the `layout_glue_generator` functions also adds a special attribute to the resulting formatting function so that when printing the layout function to the console, the user can easily interpret what's being used instead of just showing the actual functions's body. So thus if you want to write your own layout generator functions, please keep `match.call()` recorded in the `generator` attribute, or stick with standard functions. See some examples in the `layouts.R` file.

## Delivering log records to their destination

By default, `logger` will write to the console or `stdout` via the `appender_console` function:

```r
log_appender()
#> function(lines) {
#>     cat(lines, sep = '\n')
#> }
#> <environment: namespace:logger>
```

To write to a logfile instead, use the `appender_file` generator function, that returns a function that can be used in any namespace:

```r
t <- tempfile()
log_appender(appender_file(t))
log_info('where is this message going?')
log_appender()
#> appender_file(file = t)()
readLines(t)
#> [1] "INFO [2018-14-11 02:24:38] where is this message going?"
```

You may find `appender_tee` also useful, that write the log messages to both `stdout` and a file.

*Note that the `appender_file` and `appender_tee` generator functions also adds a special attribute to the resulting function so that when printing the appender function to the console, the user can easily interpret what's being used instead of just showing the actual functions's body. So thus if you want to write your own appender functions, please keep `match.call()` recorded in the `generator` attribute -- see examples in the `appenders.R` file.*

## Stacking loggers

Note that the `appender_tee` functionality can be implemented by stacking loggers as well, eg setting two loggers for the global namespace: `appender_console` and `appender_file`. The advantage of this approach is that you can set different log level thresholds for each logger, for example:

```r
log_threshold()
#> Log level: INFO

## create a new logger with index 2
log_threshold(TRACE, index = 2)

## note that the original logger still have the same log level threshold
log_threshold()
#> Log level: INFO
log_threshold(index = 2)
#> Log level: TRACE

## update the appender of the new logger
t <-tempfile()
log_appender(appender_file(t), index = 2)

## test both loggers
log_info('info msg')
#> INFO [2018-22-11 11:52:08] info msg
log_debug('info msg')

readLines(t)
#> [1] "INFO [2018-22-11 11:52:08] info msg" 
#> [2] "DEBUG [2018-22-11 11:52:13] info msg"
```

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

On the other hand, there are some low-hanging fruits to improve performance, eg caching the `logger` function in the namespace, if needed.
