# Send log messages to ntfy

Send log messages to ntfy

## Usage

``` r
appender_ntfy(title = "{logger}", tags = c("memo"), ...)
```

## Arguments

- title:

  notification title

- tags:

  emoji (or general tag) for notification. See
  [ntfy::emoji](https://jonocarroll.github.io/ntfy/reference/emoji.html)

- ...:

  extra parameters passed to
  [ntfy::ntfy_send](https://jonocarroll.github.io/ntfy/reference/ntfy_send.html)
  such as `priority`, `topic`, etc.

## Details

Configure server and topic via environment variables. See
[`ntfy::ntfy_topic()`](https://jonocarroll.github.io/ntfy/reference/ntfy_topic.html)
for details

## Note

This functionality depends on the ntfy package.

## See also

Other log_appenders:
[`appender_async()`](https://daroczig.github.io/logger/reference/appender_async.md),
[`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md),
[`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md),
[`appender_pushbullet()`](https://daroczig.github.io/logger/reference/appender_pushbullet.md),
[`appender_slack()`](https://daroczig.github.io/logger/reference/appender_slack.md),
[`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md),
[`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md),
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)
