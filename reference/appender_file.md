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
#>  [1] "INFO [2026-05-09 19:42:10] 1"  "INFO [2026-05-09 19:42:10] 2" 
#>  [3] "INFO [2026-05-09 19:42:10] 3"  "INFO [2026-05-09 19:42:10] 4" 
#>  [5] "INFO [2026-05-09 19:42:10] 5"  "INFO [2026-05-09 19:42:10] 6" 
#>  [7] "INFO [2026-05-09 19:42:10] 7"  "INFO [2026-05-09 19:42:10] 8" 
#>  [9] "INFO [2026-05-09 19:42:10] 9"  "INFO [2026-05-09 19:42:10] 10"
#> [11] "INFO [2026-05-09 19:42:10] 11" "INFO [2026-05-09 19:42:10] 12"
#> [13] "INFO [2026-05-09 19:42:10] 13" "INFO [2026-05-09 19:42:10] 14"
#> [15] "INFO [2026-05-09 19:42:10] 15" "INFO [2026-05-09 19:42:10] 16"
#> [17] "INFO [2026-05-09 19:42:10] 17" "INFO [2026-05-09 19:42:10] 18"
#> [19] "INFO [2026-05-09 19:42:10] 19" "INFO [2026-05-09 19:42:10] 20"
#> [21] "INFO [2026-05-09 19:42:10] 21" "INFO [2026-05-09 19:42:10] 22"
#> [23] "INFO [2026-05-09 19:42:10] 23" "INFO [2026-05-09 19:42:10] 24"
#> [25] "INFO [2026-05-09 19:42:10] 25"

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
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 1' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 2' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 3' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 4' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 5' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 6' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 7' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 8' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 9' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 87, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 10' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 11' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 12' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.3 to /tmp/RtmpcuBkqj/file222aadc6440/log.4
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 13' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 14' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 15' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.3 to /tmp/RtmpcuBkqj/file222aadc6440/log.4
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 16' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 17' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 18' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.3 to /tmp/RtmpcuBkqj/file222aadc6440/log.4
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 19' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 20' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 21' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.3 to /tmp/RtmpcuBkqj/file222aadc6440/log.4
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 22' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 23' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 24' to /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] lines: 3, max_lines: 3, bytes: 90, max_bytes: Inf
#> TRACE [2026-05-09 19:42:10] lines >= max_lines || bytes >= max_bytes: TRUE
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.3 to /tmp/RtmpcuBkqj/file222aadc6440/log.4
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.2 to /tmp/RtmpcuBkqj/file222aadc6440/log.3
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log.1 to /tmp/RtmpcuBkqj/file222aadc6440/log.2
#> TRACE [2026-05-09 19:42:10] renaming /tmp/RtmpcuBkqj/file222aadc6440/log to /tmp/RtmpcuBkqj/file222aadc6440/log.1
#> TRACE [2026-05-09 19:42:10] killing the main file: /tmp/RtmpcuBkqj/file222aadc6440/log
#> TRACE [2026-05-09 19:42:10] logging 'INFO [2026-05-09 19:42:10] 25' to /tmp/RtmpcuBkqj/file222aadc6440/log

## see what was logged
lapply(list.files(t, full.names = TRUE), function(t) {
  cat("\n##", t, "\n")
  cat(readLines(t), sep = "\n")
})
#> 
#> ## /tmp/RtmpcuBkqj/file222aadc6440/log 
#> INFO [2026-05-09 19:42:10] 25
#> 
#> ## /tmp/RtmpcuBkqj/file222aadc6440/log.1 
#> INFO [2026-05-09 19:42:10] 22
#> INFO [2026-05-09 19:42:10] 23
#> INFO [2026-05-09 19:42:10] 24
#> 
#> ## /tmp/RtmpcuBkqj/file222aadc6440/log.2 
#> INFO [2026-05-09 19:42:10] 19
#> INFO [2026-05-09 19:42:10] 20
#> INFO [2026-05-09 19:42:10] 21
#> 
#> ## /tmp/RtmpcuBkqj/file222aadc6440/log.3 
#> INFO [2026-05-09 19:42:10] 16
#> INFO [2026-05-09 19:42:10] 17
#> INFO [2026-05-09 19:42:10] 18
#> 
#> ## /tmp/RtmpcuBkqj/file222aadc6440/log.4 
#> INFO [2026-05-09 19:42:10] 13
#> INFO [2026-05-09 19:42:10] 14
#> INFO [2026-05-09 19:42:10] 15
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
