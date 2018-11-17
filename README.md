# logger

A modern and flexibly logging utility for R -- heavily inspired by the `futile.logger` R package and `logging` Python module.

## Installation

`logger` is not on CRAN yet, please install from GitHub:

```r
devtools::install_github('daroczig/logger')
```

## Quick examples

TODO

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

    * `formatter` function, which converts the R objects passed to the logger into an actual character vector, eg
    
        ```r
        formatter <- function(...) paste(..., collapse = ' ', sep = ' ')
        formatter(letters[1:3], 'foo', pi)
        #> [1] "a foo 3.14159265358979 b foo 3.14159265358979 c foo 3.14159265358979"
        ```
    
    * `appender` function, which writes the actual log record somewhere, eg `stdout`, a file or a streaming service, eg
    
        ```r
        appender <- function(line) cat(line, '\n')
        appender('INFO [now] I am a log message')
        #> INFO [now] I am a log message 
        ```

* user-provided parameters: 

    * actual log level, eg `INFO`, which describes the severity of a message
    * R objects to be logged

Putting all these together:

```r
TODO create logger
TODO use that logger
```

TODO describe stacking loggers

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

If you want to define the log level in a programmatic way, check out the `log` function, and see `?log_levels` for all the supported log levels.

## Log message formats

By default, the `log` function will simply record the log-level, current timestamp and the message after being processed by `glue`:

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

In the above example, first `42` was converted to a string by a message formatter, then the message was passed to a layout function to generate the actual log record.

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

To customize the format how the log messages are being rendered, see `?layout_generator` that provides very easy access to a bunch environmental variables -- quick examples on automatically logging the call from which the log message originated along with the (package) namespace, calling function's name, hostname, user running the R process etc:

* define custom logger:

    ```r
    logger <- layout_generator(msg_format = '{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}')
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
    logger.tester.function(INFO, 'hi from tester package')
    #> nevermind/21133/logger.tester/logger.tester.function 2018-14-11 01:32:56 INFO: hi from tester package
    ```

* suppress messages in a namespace:

    ```r
    log_threshold(namespace = 'logger.tester')
    #> Log level: INFO 
    log_threshold(WARN, namespace = 'logger.tester')
    logger.tester.function(INFO, 'hi from tester package')
    logger.tester.function(WARN, 'hi from tester package')
    #> nevermind/21133/logger.tester/logger.tester.function 2018-14-11 01:33:16 WARN: hi from tester package
    log_info('I am still working in the global namespace')
    #> nevermind/21133/R_GlobalEnv/NA 2018-14-11 01:33:21 INFO: I am still working in the global namespace
    ```

Note that the `layout_generator` functions also adds a special attribute to the resulting formatting function so that when printing the layout function to the console, the user can easily interpret what's being used instead of just showing the actual functions's body. So thus if you want to write your own layout generator functions, please keep `match.call()` recorded in the `generator` attribute, or stick with standard functions. See some examples in the `layouts.R` file.

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

Note that the `appender_file` and `appender_tee` generator functions also adds a special attribute to the resulting function so that when printing the appender function to the console, the user can easily interpret what's being used instead of just showing the actual functions's body. So thus if you want to write your own appender functions, please keep `match.call()` recorded in the `generator` attribute -- see examples in the `appenders.R` file.

TODO note that `tee` can be implemented by stacking loggers as well, like described above

## TODO

- [ ] doc improvements, cross-links, pkgdown, vignettes for intro and devs

- [x] support multiple appenders VS let users define a custom function wrapping multiple appenders
- [x] support multiple loggers, eg log ERROR+ to a Errbit/CloudWatch/DataDog/Splunk etc and TRACE+ to the console
- [x] allow, although do not recommend custom namespace (R pkg namespaces are just great)
- [x] refactor layout functions to use the same backend and render message either via `glue`, `sprintf` or eg `toJSON` (wontdo)

- [x] more variables inside of logger, eg call and function name
- [ ] more variables inside of logger, eg OS name/version, Jenkins or other environment variables

- [ ] `crayon`
- [ ] smarter JSON logger
- [ ] graylog, kinesis, datadog, cloudwatch, slack etc appenders

