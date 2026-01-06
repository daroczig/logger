# Send log messages to a Slack channel

Send log messages to a Slack channel

## Usage

``` r
appender_slack(
  channel = Sys.getenv("SLACK_CHANNEL"),
  username = Sys.getenv("SLACK_USERNAME"),
  icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
  api_token = Sys.getenv("SLACK_API_TOKEN"),
  preformatted = TRUE
)
```

## Arguments

- channel:

  Slack channel name with a hashtag prefix for public channel and no
  prefix for private channels

- username:

  Slack (bot) username

- icon_emoji:

  optional override for the bot icon

- api_token:

  Slack API token

- preformatted:

  use code tags around the message?

## Value

function taking `lines` argument

## Note

This functionality depends on the slackr package.

## See also

Other log_appenders:
[`appender_async()`](https://daroczig.github.io/logger/reference/appender_async.md),
[`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md),
[`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md),
[`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md),
[`appender_pushbullet()`](https://daroczig.github.io/logger/reference/appender_pushbullet.md),
[`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md),
[`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md),
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)
