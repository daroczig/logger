# Send log messages to the POSIX system log

Send log messages to the POSIX system log

## Usage

``` r
appender_syslog(identifier, ...)
```

## Arguments

- identifier:

  A string identifying the process.

- ...:

  Further arguments passed on to
  [`rsyslog::open_syslog()`](https://rdrr.io/pkg/rsyslog/man/syslog.html).

## Value

function taking `lines` argument

## Note

This functionality depends on the rsyslog package.

## See also

Other log_appenders:
[`appender_async()`](https://daroczig.github.io/logger/reference/appender_async.md),
[`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md),
[`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md),
[`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md),
[`appender_pushbullet()`](https://daroczig.github.io/logger/reference/appender_pushbullet.md),
[`appender_slack()`](https://daroczig.github.io/logger/reference/appender_slack.md),
[`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md),
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("rsyslog", quietly = TRUE)) {
  log_appender(appender_syslog("test"))
  log_info("Test message.")
}
} # }
```
