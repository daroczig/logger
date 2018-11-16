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
- support vectorization (eg passing a vector to be logged on multiple lines)
- make it easy to extend with new features (eg layouts, message formats and output)
- prepare for writing to various services
- provide support for namespaces, preferably automatically finding and creating a custom namespace for all R packages writing log messages -- each with optionally configurable log level threshold, message and output formats
- optionally colorize log message based on the log level
- make logging fun

Welcome to the Bazaar!

## The structure of a log record

Minimum requirements of a logger object and its required parameters to log something:

* logger definition:

    * log level `threshold`, eg `ERROR`, which defines the minimum log level required for actual logging
    * `layout` function, which defines the format of a log record, eg 

        * structured text including log level, timestamp and message
        
            ```
            INFO [1970-01-01 00:00:00] I'm alive!
            ```
        
        * a JSON object of log level, timestamp, hostname, calling function and message
        
            ```
            {'level': 'INFO', 'timestamp': '1970-01-01 00:00:00', 'hostname': 'foobar', 'message': 'I\'m alive!'}
            ```

    * `formatter` function, which converts the R objects passed to the logger into an actual character vector
    * `appender` function, which writes the actual log record somewhere, eg `stdout`, a file or a streaming service

* parameters: 

    * actual log level, eg `INFO`, which describes the severity of a message
    * some other parameters describing the environment of the log record are automatically captured, eg timestamp, hostname, username, calling function etc.
    * R objects to be logged

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

There's also a simple layout writing log message to JSON:


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

## Log devices

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

## TODO

- [ ] more variables inside of logger, eg call and function name
- [ ] refactor layout functions to use the same backend and render message either via `glue`, `sprintf` or eg `toJSON`
- [ ] `crayon`
- [ ] smarter JSON logger
- [ ] graylog, kinesis, datadog, cloudwatch, slack etc appenders

