# Customizing the Format and the Destination of a Log Record

In this vignette I suppose that you are already familiar with [The
Anatomy of a Log
Request](https://daroczig.github.io/logger/articles/anatomy.html)
vignette.

## What gets logged?

`logger` mostly relies on and uses the default `log4j` log levels and
supports suppressing log messages with a lower log level compared to the
currently set threshold in the logging namespace:

``` r

log_info("Hi, there!")
#> INFO [2026-05-08 20:47:37] Hi, there!
log_debug("How are you doing today?")
log_threshold()
#> Log level: INFO
log_threshold(TRACE)
log_debug("How are you doing today?")
#> DEBUG [2026-05-08 20:47:37] How are you doing today?
```

So the
[`?log_threshold`](https://daroczig.github.io/logger/reference/log_threshold.md)
function can both get and set the log level threshold for all future log
requests.

For the full list of all supported log levels and so thus the possible
log level thresholds, see
[`?log_levels`](https://daroczig.github.io/logger/reference/log_levels.md).

If you want to define the log level in a programmatic way, check out
[`?log_level`](https://daroczig.github.io/logger/reference/log_level.md),
eg

``` r

log_level(INFO, "Hi, there!")
#> INFO [2026-05-08 20:47:37] Hi, there!
```

To temporarily update the log level threshold, you may also find the
[`?with_log_threshold`](https://daroczig.github.io/logger/reference/with_log_threshold.md)
function useful:

``` r

log_threshold(INFO)
log_debug("pst, can you hear me?")
log_info("no")
#> INFO [2026-05-08 20:47:37] no

with_log_threshold(log_debug("pst, can you hear me?"), threshold = TRACE)
#> DEBUG [2026-05-08 20:47:37] pst, can you hear me?
log_info("yes")
#> INFO [2026-05-08 20:47:37] yes

with_log_threshold(
  {
    log_debug("pst, can you hear me?")
    log_info("yes")
  },
  threshold = TRACE
)
#> DEBUG [2026-05-08 20:47:37] pst, can you hear me?
#> INFO [2026-05-08 20:47:37] yes
```

You can also define your own log level(s) if needed, for example
introducing an extra level between `DEBUG` and `INFO`:

``` r

FYI <- structure(450L, level = "FYI", class = c("loglevel", "integer"))
log_threshold(FYI)
log_debug("ping")
log_level(FYI, "ping")
#> FYI [2026-05-08 20:47:37] ping
log_info("pong")
#> INFO [2026-05-08 20:47:37] pong
```

## Log namespaces

By default, all log messages will be processed by the global `logger`
definition, but you may also use custom namespaces (eg to deliver
specific log records to a special destination or to apply a custom log
level threshold) and even multiple loggers as well within the very same
namespace (eg to deliver all `INFO` and above log levels in the console
and everything below that to a trace log file).

If you specify an unknown `namespace` in a log request, it will fall
back to the global settings:

``` r

log_threshold(INFO)
log_trace("Hi, there!", namespace = "kitchensink")
log_info("Hi, there!", namespace = "kitchensink")
#> INFO [2026-05-08 20:47:37] Hi, there!
```

But once you start customizing that namespace, it gets forked from the
global settings and live on its own without modifying the original
namespace:

``` r

log_threshold(TRACE, namespace = "kitchensink")
log_trace("Hi, there!", namespace = "kitchensink")
#> TRACE [2026-05-08 20:47:37] Hi, there!
log_info("Hi, there!", namespace = "kitchensink")
#> INFO [2026-05-08 20:47:37] Hi, there!
log_trace("Hi, there!")
```

## Log message formatter functions

In the above example, we logged strings without any dynamic parameter,
so the task of the logger was quite easy. But in most cases you want to
log a parameterized string and the formatter function’s task to
transform that to a regular character vector.

By default, `logger` uses `glue` in the background:

``` r

log_formatter(formatter_glue)
log_info("There are {nrow(mtcars)} cars in the mtcars dataset")
#> INFO [2026-05-08 20:47:37] There are 32 cars in the mtcars dataset
log_info("2 + 2 = {2+2}")
#> INFO [2026-05-08 20:47:37] 2 + 2 = 4
```

If you don’t like this syntax, or want to save a dependency, you can use
other formatter functions as well, such as
[`?formatter_sprintf`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)
(being the default in eg the [`logging` and `futile.logger`
packages](https://daroczig.github.io/logger/articles/migration.html)) or
[`?formatter_paste`](https://daroczig.github.io/logger/reference/formatter_paste.md),
or [write your own formatter
function](https://daroczig.github.io/logger/articles/write_custom_extensions.html)
converting R objects into string.

## Log message layouts

By default,
[`?log_level`](https://daroczig.github.io/logger/reference/log_level.md)
and its derivative functions (eg
[`?log_info`](https://daroczig.github.io/logger/reference/log_level.md))
will simply record the log-level, the current timestamp and the message
after being processed by `glue`:

``` r

log_info(42)
#> INFO [2026-05-08 20:47:37] 42
log_info("The answer is {42}")
#> INFO [2026-05-08 20:47:37] The answer is 42
log_info("The answers are {1:5}")
#> INFO [2026-05-08 20:47:37] The answers are 1
#> INFO [2026-05-08 20:47:37] The answers are 2
#> INFO [2026-05-08 20:47:37] The answers are 3
#> INFO [2026-05-08 20:47:37] The answers are 4
#> INFO [2026-05-08 20:47:37] The answers are 5
```

In the above example, first, `42` was converted to a string by the
[`?formatter_glue`](https://daroczig.github.io/logger/reference/formatter_glue.md)
message formatter, then the message was passed to the
[`?layout_simple`](https://daroczig.github.io/logger/reference/layout_simple.md)
layout function to generate the actual log record.

An example of another layout function writing the same log messages in
JSON:

``` r

log_layout(layout_json())
log_info(42)
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"42"}
log_info("The answer is {42}")
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answer is 42"}
log_info("The answers are {1:5}")
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answers are 1"}
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answers are 2"}
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answers are 3"}
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answers are 4"}
#> {"time":"2026-05-08 20:47:38","level":"INFO","ns":"global","ans":"global","topenv":"R_GlobalEnv","fn":"eval","node":"runnervmeorf1","arch":"x86_64","os_name":"Linux","os_release":"6.17.0-1010-azure","os_version":"#10~24.04.1-Ubuntu SMP Fri Mar  6 22:00:57 UTC 2026","pid":11873,"user":"runner","msg":"The answers are 5"}
```

If you need colorized logs highlighting the important log messages,
check out
[`?layout_glue_colors`](https://daroczig.github.io/logger/reference/layout_glue_colors.md),
and for other formatter and layout functions, see the manual of the
above mentioned functions that have references to all the other
functions and generator functions bundled with the package.

## Custom log record layout

To define a custom format on how the log messages should be rendered,
you may write your own `formatter` and `layout` function(s) or rely on
the function generator functions bundled with the `logger` package, such
as
[`?layout_glue_generator`](https://daroczig.github.io/logger/reference/layout_glue_generator.md).

This function returns a `layout` function that you can define by
`glue`-ing together variables describing the log request via
[`?get_logger_meta_variables`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md),
so having easy access to (package) namespace, calling function’s name,
hostname, user running the R process etc.

A quick example:

- define custom logger:

  ``` r

  logger <- layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
  log_layout(logger)
  ```

- check what’s being logged when called from the global environment:

  ``` r

  log_info("foo")
  #> runnervmeorf1/11873/global/eval 2026-05-08 20:47:38.170184 INFO: foo
  ```

- check what’s being logged when called from a custom function:

  ``` r

  f <- function() log_info("foo")
  f()
  #> runnervmeorf1/11873/global/f 2026-05-08 20:47:38.229801 INFO: foo
  ```

- check what’s being logged when called from a package:

  ``` r

  devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"))
  #> ℹ Loading logger.tester
  logger_tester_function(INFO, "hi from tester package")
  #> runnervmeorf1/11873/logger.tester/logger_tester_function 2026-05-08 20:47:38.400035 INFO: hi from tester package 0.0807501375675201
  ```

- suppress messages in a namespace:

  ``` r

  log_threshold(namespace = "logger.tester")
  #> Log level: INFO
  log_threshold(WARN, namespace = "logger.tester")
  logger_tester_function(INFO, "hi from tester package")
  logger_tester_function(WARN, "hi from tester package")
  #> runnervmeorf1/11873/logger.tester/logger_tester_function 2026-05-08 20:47:38.466082 WARN: hi from tester package 0.0807501375675201
  log_info("I am still working in the global namespace")
  #> runnervmeorf1/11873/global/eval 2026-05-08 20:47:38.467375 INFO: I am still working in the global namespace
  ```

Another example of making use of the generator function is to update the
layout to include the Process ID that might be very useful eg when
forking, see for example the below code chunk still using the above
defined log layout:

``` r

f <- function(x) {
    log_info('received {length(x)} values')
    log_success('with the mean of {mean(x)}')
    mean(x)
}
library(parallel)
mclapply(split(runif(100), 1:10), f, mc.cores = 5)
#> nevermind/26448/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26448/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.403173440974206
#> nevermind/26449/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26448/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26449/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.538581100990996
#> nevermind/26448/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.485734378430061
#> nevermind/26450/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26449/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26450/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.580483326432295
#> nevermind/26452/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26449/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.461282140854746
#> nevermind/26450/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26451/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26450/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.465152264293283
#> nevermind/26452/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.618332817289047
#> nevermind/26451/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.493527933699079
#> nevermind/26452/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26452/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.606248055002652
#> nevermind/26451/R_GlobalEnv/FUN 2018-12-02 21:54:11 INFO: received 10 values
#> nevermind/26451/R_GlobalEnv/FUN 2018-12-02 21:54:11 SUCCESS: with the mean of 0.537314630229957
```

*Note that the `layout_glue_generator` functions also adds a special
attribute to the resulting formatting function so that when printing the
layout function to the console, the user can easily interpret what’s
being used instead of just showing the actual functions’s body:*

``` r

log_layout()
#> layout_glue_generator(format = "{node}/{pid}/{namespace}/{fn} {time} {level}: {msg}")
```

For more details on this, see the [Writing custom logger
extensions](https://daroczig.github.io/logger/articles/write_custom_extensions.html)
vignette.

``` r

## reset layout
log_layout(layout_simple)
```

## Delivering log records to their destination

By default, `logger` will write to the `stderr` via the
[`?appender_console`](https://daroczig.github.io/logger/reference/appender_console.md)
function:

``` r

log_appender()
#> appender_stdout
```

To write to a logfile instead, use the
[`?appender_file`](https://daroczig.github.io/logger/reference/appender_file.md)
generator function, that returns a function that can be used in any
namespace:

``` r

t <- tempfile()
log_appender(appender_file(t))
log_info("where is this message going?")
log_appender()
#> appender_file(file = t)
readLines(t)
#> [1] "INFO [2026-05-08 20:47:38] where is this message going?"
unlink(t)
```

There’s a similar generator function that returns an appender function
delivering log messages to Slack channels:

``` r

## load Slack configuration, API token etc from a (hopefully encrypted) yaml file or similar
slack_config <- config::config(...)
## redirect log messages to Slack
log_appender(appender_slack(
    channel   = '#gergely-test',
    username  = 'logger',
    api_token = slack_config$token
), namespace = 'slack')
log_info('Excited about sending logs to Slack!')
#> INFO [2018-11-28 00:21:13] Excited about sending logs to Slack!
log_info('Hi there from logger@R!', namespace = 'slack')
```

You may find
[`?appender_tee`](https://daroczig.github.io/logger/reference/appender_tee.md)
also useful, that writes the log messages to both `stdout` and a file.

``` r

## reset appender
log_appender(appender_stdout)
```

And the are many other appender functions bundled with `logger` as well,
eg some writing to Syslog, Telegram, Pushbullet, a database table or an
Amazon Kinesis stream – even doing that asynchronously via
`appender_async` – see [Simple Benchmarks on
Performance](https://daroczig.github.io/logger/articles/performance.html)
for more details.

## Stacking loggers

Note that the
[`?appender_tee`](https://daroczig.github.io/logger/reference/appender_tee.md)
functionality can be implemented by stacking loggers as well, eg setting
two loggers for the global namespace:
[`?appender_console`](https://daroczig.github.io/logger/reference/appender_console.md)
and
[`?appender_file`](https://daroczig.github.io/logger/reference/appender_file.md).
The advantage of this approach is that you can set different log level
thresholds for each logger, for example:

``` r

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
t <- tempfile()
log_appender(appender_file(t), index = 2)

## test both loggers
log_info("info msg")
#> INFO [2026-05-08 20:47:38] info msg
log_debug("info msg")

readLines(t)
#> [1] "INFO [2026-05-08 20:47:38] info msg" 
#> [2] "DEBUG [2026-05-08 20:47:38] info msg"
unlink(t)
```
