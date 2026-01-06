# Append log messages to a file

Log messages are written to a file with basic log rotation: when max
number of lines or bytes is defined to be other than `Inf`, then the log
file is renamed with a `.1` suffix and a new log file is created. The
renaming happens recursively (eg `logfile.1` renamed to `logfile.2`)
until the specified `max_files`, then the oldest file
(`logfile.{max_files-1}`) is deleted.

## Usage

``` r
appender_file(
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
## ##########################################################################
## simple example logging to a file
t <- tempfile()
log_appender(appender_file(t))
for (i in 1:25) log_info(i)
readLines(t)
#>  [1] "INFO [2026-01-06 21:42:55] 1"  "INFO [2026-01-06 21:42:55] 2" 
#>  [3] "INFO [2026-01-06 21:42:55] 3"  "INFO [2026-01-06 21:42:55] 4" 
#>  [5] "INFO [2026-01-06 21:42:55] 5"  "INFO [2026-01-06 21:42:55] 6" 
#>  [7] "INFO [2026-01-06 21:42:55] 7"  "INFO [2026-01-06 21:42:55] 8" 
#>  [9] "INFO [2026-01-06 21:42:55] 9"  "INFO [2026-01-06 21:42:55] 10"
#> [11] "INFO [2026-01-06 21:42:55] 11" "INFO [2026-01-06 21:42:55] 12"
#> [13] "INFO [2026-01-06 21:42:55] 13" "INFO [2026-01-06 21:42:55] 14"
#> [15] "INFO [2026-01-06 21:42:55] 15" "INFO [2026-01-06 21:42:55] 16"
#> [17] "INFO [2026-01-06 21:42:55] 17" "INFO [2026-01-06 21:42:55] 18"
#> [19] "INFO [2026-01-06 21:42:55] 19" "INFO [2026-01-06 21:42:55] 20"
#> [21] "INFO [2026-01-06 21:42:55] 21" "INFO [2026-01-06 21:42:55] 22"
#> [23] "INFO [2026-01-06 21:42:55] 23" "INFO [2026-01-06 21:42:55] 24"
#> [25] "INFO [2026-01-06 21:42:55] 25"

## ##########################################################################
## more complex example of logging to file
## rotated after every 3rd line up to max 5 files

## create a folder storing the log files
t <- tempfile()
dir.create(t)
f <- file.path(t, "log")

## define the file logger with log rotation enabled
log_appender(appender_file(f, max_lines = 3, max_files = 5L))

## enable internal logging to see what's actually happening in the logrotate steps
log_threshold(TRACE, namespace = ".logger")
## log 25 messages
for (i in 1:25) log_info(i)
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:55] 1' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 2' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 3' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 4' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 5' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 6' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 7' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 8' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 9' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 10' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 11' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 12' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.3 to /tmp/Rtmp4NmESW/file23c27305e628/log.4
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 13' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 14' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 15' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.3 to /tmp/Rtmp4NmESW/file23c27305e628/log.4
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 16' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 17' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 18' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.3 to /tmp/Rtmp4NmESW/file23c27305e628/log.4
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 19' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 20' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 21' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.3 to /tmp/Rtmp4NmESW/file23c27305e628/log.4
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 22' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 23' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 24' to /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-01-06 21:42:56] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.3 to /tmp/Rtmp4NmESW/file23c27305e628/log.4
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.2 to /tmp/Rtmp4NmESW/file23c27305e628/log.3
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log.1 to /tmp/Rtmp4NmESW/file23c27305e628/log.2
#> TRACE [2026-01-06 21:42:56] renaming /tmp/Rtmp4NmESW/file23c27305e628/log to /tmp/Rtmp4NmESW/file23c27305e628/log.1
#> TRACE [2026-01-06 21:42:56] killing the main file: /tmp/Rtmp4NmESW/file23c27305e628/log
#> TRACE [2026-01-06 21:42:56] logging 'INFO [2026-01-06 21:42:56] 25' to /tmp/Rtmp4NmESW/file23c27305e628/log

## see what was logged
lapply(list.files(t, full.names = TRUE), function(t) {
  cat("\n##", t, "\n")
  cat(readLines(t), sep = "\n")
})
#> 
#> ## /tmp/Rtmp4NmESW/file23c27305e628/log 
#> INFO [2026-01-06 21:42:56] 25
#> 
#> ## /tmp/Rtmp4NmESW/file23c27305e628/log.1 
#> INFO [2026-01-06 21:42:56] 22
#> INFO [2026-01-06 21:42:56] 23
#> INFO [2026-01-06 21:42:56] 24
#> 
#> ## /tmp/Rtmp4NmESW/file23c27305e628/log.2 
#> INFO [2026-01-06 21:42:56] 19
#> INFO [2026-01-06 21:42:56] 20
#> INFO [2026-01-06 21:42:56] 21
#> 
#> ## /tmp/Rtmp4NmESW/file23c27305e628/log.3 
#> INFO [2026-01-06 21:42:56] 16
#> INFO [2026-01-06 21:42:56] 17
#> INFO [2026-01-06 21:42:56] 18
#> 
#> ## /tmp/Rtmp4NmESW/file23c27305e628/log.4 
#> INFO [2026-01-06 21:42:56] 13
#> INFO [2026-01-06 21:42:56] 14
#> INFO [2026-01-06 21:42:56] 15
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL
#> 
#> [[3]]
#> NULL
#> 
#> [[4]]
#> NULL
#> 
#> [[5]]
#> NULL
#> 
```
