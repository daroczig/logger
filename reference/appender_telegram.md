# Send log messages to a Telegram chat

Send log messages to a Telegram chat

## Usage

``` r
appender_telegram(
  chat_id = Sys.getenv("TELEGRAM_CHAT_ID"),
  bot_token = Sys.getenv("TELEGRAM_BOT_TOKEN"),
  parse_mode = NULL
)
```

## Arguments

- chat_id:

  Unique identifier for the target chat or username of the target
  channel (in the format @channelusername)

- bot_token:

  Telegram Authorization token

- parse_mode:

  Message parse mode. Allowed values: Markdown or HTML

## Value

function taking `lines` argument

## Note

This functionality depends on the telegram package.

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
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md)
