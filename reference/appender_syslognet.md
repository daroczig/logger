# Send log messages to a network syslog server

Send log messages to a network syslog server

## Usage

``` r
appender_syslognet(identifier, server, port = 601L)
```

## Arguments

- identifier:

  program/function identification (string).

- server:

  machine where syslog daemon runs (string).

- port:

  port where syslog daemon listens (integer).

## Value

A function taking a `lines` argument.

## Note

This functionality depends on the syslognet package.

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("syslognet", quietly = TRUE)) {
  log_appender(appender_syslognet("test_app", "remoteserver"))
  log_info("Test message.")
}
} # }
```
