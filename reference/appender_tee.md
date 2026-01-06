# Append log messages to a file and stdout as well

This appends log messages to both console and a file. The same rotation
options are available as in
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md).

## Usage

``` r
appender_tee(
  file,
  append = TRUE,
  max_lines = Inf,
  max_bytes = Inf,
  max_files = 1L
)
```

## Arguments

- file:

  path

- append:

  boolean passed to `cat` defining if the file should be overwritten
  with the most recent log message instead of appending

- max_lines:

  numeric specifying the maximum number of lines allowed in a file
  before rotating

- max_bytes:

  numeric specifying the maximum number of bytes allowed in a file
  before rotating

- max_files:

  integer specifying the maximum number of files to be used in rotation

## Value

function taking `lines` argument

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
[`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)
