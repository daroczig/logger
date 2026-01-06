# Delays executing the actual appender function to the future in a background process to avoid blocking the main R session

Delays executing the actual appender function to the future in a
background process to avoid blocking the main R session

## Usage

``` r
appender_async(
  appender,
  namespace = "async_logger",
  init = function() log_info("Background process started")
)
```

## Arguments

- appender:

  a
  [`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md)
  function with a `generator` attribute (TODO note not required, all fn
  will be passed if not)

- namespace:

  `logger` namespace to use for logging messages on starting up the
  background process

- init:

  optional function to run in the background process that is useful to
  set up the environment required for logging, eg if the `appender`
  function requires some extra packages to be loaded or some environment
  variables to be set etc

## Value

function taking `lines` argument

## Note

This functionality depends on the mirai package.

## See also

Other log_appenders:
[`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md),
[`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md),
[`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md),
[`appender_pushbullet()`](https://daroczig.github.io/logger/reference/appender_pushbullet.md),
[`appender_slack()`](https://daroczig.github.io/logger/reference/appender_slack.md),
[`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md),
[`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md),
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)

## Examples

``` r
if (FALSE) { # \dontrun{
appender_file_slow <- function(file) {
  force(file)
  function(lines) {
    Sys.sleep(1)
    cat(lines, sep = "\n", file = file, append = TRUE)
  }
}

## log what's happening in the background
log_threshold(TRACE, namespace = "async_logger")
log_appender(appender_console, namespace = "async_logger")

## start async appender
t <- tempfile()
log_info("Logging in the background to {t}")

## use async appender
log_appender(appender_async(appender_file_slow(file = t)))
log_info("Was this slow?")
system.time(for (i in 1:25) log_info(i))

readLines(t)
Sys.sleep(10)
readLines(t)

} # }
```
