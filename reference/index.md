# Package index

## Key logging functions

- [`log_level()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_fatal()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_error()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_warn()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_success()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_info()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_debug()`](https://daroczig.github.io/logger/reference/log_level.md)
  [`log_trace()`](https://daroczig.github.io/logger/reference/log_level.md)
  : Log a message with given log level
- [`OFF`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`FATAL`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`ERROR`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`WARN`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`SUCCESS`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`INFO`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`DEBUG`](https://daroczig.github.io/logger/reference/log_levels.md)
  [`TRACE`](https://daroczig.github.io/logger/reference/log_levels.md) :
  Log levels
- [`log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.md)
  : Get or set log level threshold

## Other logging helpers

- [`log_eval()`](https://daroczig.github.io/logger/reference/log_eval.md)
  : Evaluate an expression and log results
- [`log_failure()`](https://daroczig.github.io/logger/reference/log_failure.md)
  : Logs the error message to console before failing
- [`log_tictoc()`](https://daroczig.github.io/logger/reference/log_tictoc.md)
  : Tic-toc logging
- [`log_elapsed()`](https://daroczig.github.io/logger/reference/log_elapsed.md)
  [`log_elapsed_start()`](https://daroczig.github.io/logger/reference/log_elapsed.md)
  : Log cumulative running time
- [`log_separator()`](https://daroczig.github.io/logger/reference/log_separator.md)
  : Logs a long line to stand out from the console
- [`log_with_separator()`](https://daroczig.github.io/logger/reference/log_with_separator.md)
  : Logs a message in a very visible way
- [`with_log_threshold()`](https://daroczig.github.io/logger/reference/with_log_threshold.md)
  : Evaluate R expression with a temporarily updated log level threshold
- [`log_chunk_time()`](https://daroczig.github.io/logger/reference/log_chunk_time.md)
  : Automatically log execution time of knitr chunks

## Appenders

Log appenders define where logging output should be sent to.

- [`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md)
  : Get or set log record appender function
- [`appender_async()`](https://daroczig.github.io/logger/reference/appender_async.md)
  : Delays executing the actual appender function to the future in a
  background process to avoid blocking the main R session
- [`appender_console()`](https://daroczig.github.io/logger/reference/appender_console.md)
  [`appender_stderr()`](https://daroczig.github.io/logger/reference/appender_console.md)
  : Append log record to stderr
- [`appender_file()`](https://daroczig.github.io/logger/reference/appender_file.md)
  : Append log messages to a file
- [`appender_kinesis()`](https://daroczig.github.io/logger/reference/appender_kinesis.md)
  : Send log messages to a Amazon Kinesis stream
- [`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md)
  : Send log messages to ntfy
- [`appender_pushbullet()`](https://daroczig.github.io/logger/reference/appender_pushbullet.md)
  : Send log messages to Pushbullet
- [`appender_slack()`](https://daroczig.github.io/logger/reference/appender_slack.md)
  : Send log messages to a Slack channel
- [`appender_stdout()`](https://daroczig.github.io/logger/reference/appender_stdout.md)
  : Append log record to stdout
- [`appender_syslog()`](https://daroczig.github.io/logger/reference/appender_syslog.md)
  : Send log messages to the POSIX system log
- [`appender_syslognet()`](https://daroczig.github.io/logger/reference/appender_syslognet.md)
  : Send log messages to a network syslog server
- [`appender_tee()`](https://daroczig.github.io/logger/reference/appender_tee.md)
  : Append log messages to a file and stdout as well
- [`appender_telegram()`](https://daroczig.github.io/logger/reference/appender_telegram.md)
  : Send log messages to a Telegram chat
- [`appender_void()`](https://daroczig.github.io/logger/reference/appender_void.md)
  : Dummy appender not delivering the log record to anywhere

## Formatters

Log formatters control how the inputs to the `log_` functions are
converted to a string. The default is
[`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md)
when `glue` is installed.

- [`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md)
  : Get or set log message formatter

- [`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md)
  :

  Apply
  [`cli::cli_text()`](https://cli.r-lib.org/reference/cli_text.html) to
  format string with cli syntax

- [`formatter_glue()`](https://daroczig.github.io/logger/reference/formatter_glue.md)
  :

  Apply [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)
  to convert R objects into a character vector

- [`formatter_glue_or_sprintf()`](https://daroczig.github.io/logger/reference/formatter_glue_or_sprintf.md)
  :

  Apply [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)
  and [`sprintf()`](https://rdrr.io/r/base/sprintf.html)

- [`formatter_glue_safe()`](https://daroczig.github.io/logger/reference/formatter_glue_safe.md)
  :

  Apply
  [`glue::glue_safe()`](https://glue.tidyverse.org/reference/glue_safe.html)
  to convert R objects into a character vector

- [`formatter_json()`](https://daroczig.github.io/logger/reference/formatter_json.md)
  : Transforms all passed R objects into a JSON list

- [`formatter_logging()`](https://daroczig.github.io/logger/reference/formatter_logging.md)
  :

  Mimic the default formatter used in the logging package

- [`formatter_pander()`](https://daroczig.github.io/logger/reference/formatter_pander.md)
  : Formats R objects with pander

- [`formatter_paste()`](https://daroczig.github.io/logger/reference/formatter_paste.md)
  :

  Concatenate R objects into a character vector via `paste`

- [`formatter_sprintf()`](https://daroczig.github.io/logger/reference/formatter_sprintf.md)
  :

  Apply [`sprintf()`](https://rdrr.io/r/base/sprintf.html) to convert R
  objects into a character vector

- [`skip_formatter()`](https://daroczig.github.io/logger/reference/skip_formatter.md)
  : Skip the formatter function

## Layouts

Logging layouts control what is sent to the appender. They always
include the logged string, but might also include the timestamp, log
level, etc.

- [`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md)
  : Get or set log record layout

- [`layout_blank()`](https://daroczig.github.io/logger/reference/layout_blank.md)
  : Format a log record by including the raw message without anything
  added or modified

- [`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md)
  : Format a log record for github actions

- [`layout_glue()`](https://daroczig.github.io/logger/reference/layout_glue.md)
  :

  Format a log message with
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html)

- [`layout_glue_colors()`](https://daroczig.github.io/logger/reference/layout_glue_colors.md)
  :

  Format a log message with
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) and
  ANSI escape codes to add colors

- [`layout_glue_generator()`](https://daroczig.github.io/logger/reference/layout_glue_generator.md)
  : Generate log layout function using common variables available via
  glue syntax

- [`layout_json()`](https://daroczig.github.io/logger/reference/layout_json.md)
  : Generate log layout function rendering JSON

- [`layout_json_parser()`](https://daroczig.github.io/logger/reference/layout_json_parser.md)
  : Generate log layout function rendering JSON after merging meta
  fields with parsed list from JSON message

- [`layout_logging()`](https://daroczig.github.io/logger/reference/layout_logging.md)
  : Format a log record as the logging package does by default

- [`layout_simple()`](https://daroczig.github.io/logger/reference/layout_simple.md)
  : Format a log record by concatenating the log level, timestamp and
  message

- [`layout_syslognet()`](https://daroczig.github.io/logger/reference/layout_syslognet.md)
  : Format a log record for syslognet

## Hooks for automated logging

- [`log_shiny_input_changes()`](https://daroczig.github.io/logger/reference/log_shiny_input_changes.md)
  : Auto logging input changes in Shiny app
- [`log_messages()`](https://daroczig.github.io/logger/reference/log_messages.md)
  : Injects a logger call to standard messages
- [`log_warnings()`](https://daroczig.github.io/logger/reference/log_warnings.md)
  : Injects a logger call to standard warnings
- [`log_errors()`](https://daroczig.github.io/logger/reference/log_errors.md)
  : Injects a logger call to standard errors

## Other helpers

- [`colorize_by_log_level()`](https://daroczig.github.io/logger/reference/colorize_by_log_level.md)
  [`grayscale_by_log_level()`](https://daroczig.github.io/logger/reference/colorize_by_log_level.md)
  : Color string by the related log level
- [`logger()`](https://daroczig.github.io/logger/reference/logger.md) :
  Generate logging utility
- [`delete_logger_index()`](https://daroczig.github.io/logger/reference/delete_logger_index.md)
  : Delete an index from a logger namespace
- [`` `%except%` ``](https://daroczig.github.io/logger/reference/grapes-except-grapes.md)
  : Try to evaluate an expressions and evaluate another expression on
  exception

## Dev tools

- [`as.loglevel()`](https://daroczig.github.io/logger/reference/as.loglevel.md)
  : Convert R object into a logger log-level
- [`deparse_to_one_line()`](https://daroczig.github.io/logger/reference/deparse_to_one_line.md)
  : Deparse and join all lines into a single line
- [`fail_on_missing_package()`](https://daroczig.github.io/logger/reference/fail_on_missing_package.md)
  : Check if R package can be loaded and fails loudly otherwise
- [`get_logger_meta_variables()`](https://daroczig.github.io/logger/reference/get_logger_meta_variables.md)
  : Collect useful information about the logging environment to be used
  in log messages
- [`log_namespaces()`](https://daroczig.github.io/logger/reference/log_namespaces.md)
  : Looks up logger namespaces
- [`log_indices()`](https://daroczig.github.io/logger/reference/log_indices.md)
  : Returns number of currently active indices
