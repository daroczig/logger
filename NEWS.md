# logger 0.1.9000 (2019-09-06)

## Breaking changes

* `appender_console` writes to `stderr` by default instead of `stdout` (#28)

## New features

* new helper function to evaluate an expression with fallback
* allow defining the log level threshold as character (#13, @artemklevtsov)
* new appender function to deliver log records to Telegram (#14, @artemklevtsov)
* new helper functions for logging with separator lines (#16)
* new helper function for tic-toc logging (#16)
* new helper function to log error before failing (#19, @amy17519)
* new helper functions injecting `logger` calls to `message`, `warnings` and `stop` to optionally auto-log messages, warnings and errors
* improved performance by not evaluating arguments when the log record does not meet the log level threshold (#27, @jozefhajnala)
* new argument to `appender_file` to optionally truncate before appending (#24, @eddelbuettel)
* new helper function to auto-log input changes in Shiny apps (#25)
* new appender function to deliver log records to syslog (#30, @atheriel)
* new appender function to deliver log records to Amazon Kinesis (#35)
* new wrapper function for appender functions to deliver log records in a background process asynchronously without blocking the master process (#35)
* new layout function returning blank log messages without any modification

TODO reorder into categories (eg helpers, appenders etc)

# logger 0.1 (2018-12-20)

Initial CRAN release after collecting feedback for a month on [Twitter](https://twitter.com/daroczig/status/1067461632677330944):

* finalized design of a log request defined by

    * a log level `threshold`,
    * a `formatter` function preparing the log message,
    * a `layout` function rendering the actual log records and
    * an `appender` function delivering to the log destination

* detailed documentation with 7 vignettes and a lot of examples, even some benchmarks
* ~75% code coverage for unit tests
* 5 `formatter` functions mostly using `paste`, `sprintf` and `glue`
* 6 `layout` functions with convenient wrappers to let users define custom layouts via `glue` or `JSON`, including colorized output
* 5 `appender` functions delivering log records to the console, files, Pushbullet and Slack
* helper function to evaluate an expressions with auto-logging both the expression and its result
* helper function to temporarily update the log level threshold
* helper function to skip running the formatter function on a log message
* mostly backward compatibly with the `logging` and `futile.logger` packages
