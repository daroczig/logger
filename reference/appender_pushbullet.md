# Send log messages to Pushbullet

Send log messages to Pushbullet

## Usage

``` r
appender_pushbullet(...)
```

## Arguments

- ...:

  parameters passed to
  [RPushbullet::pbPost](https://rdrr.io/pkg/RPushbullet/man/pbPost.html),
  such as `recipients` or `apikey`, although it's probably much better
  to set all these in the `~/.rpushbullet.json` as per package docs at
  [http://dirk.eddelbuettel.com/code/rpushbullet.html](http://dirk.eddelbuettel.com/code/rpushbullet.md)

## Note

This functionality depends on the RPushbullet package.

## See also

Other log_appenders:
[`appender_async()`](https://daroczig.github.io/logger/reference/appender_async.md),
[`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md),
[`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md),
[`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md),
[`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md),
[`appender_slack()`](https://daroczig.github.io/logger/reference/appender_slack.md),
[`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md),
[`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md),
[`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md),
[`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)
