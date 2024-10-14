# logger (development version)

## New features

* logo 😻 (#196, @hadley)
* computing metadata lazily, so various expensive computations are only performed if you actually add them to the log (#105, @hadley)
* `log_appender()`, `log_layout()` and `log_formatter()` now check that you are calling them with a function, and return the previously set value (#170, @hadley)
* new function to return number of log indices (#194, @WurmPeter)
* `appender_async` is now using `mirai` instead of a custom background process and queue system (#214, @hadley @shikokuchuo)

## Fixes

* `eval` scoping and lazy eval (#178, @hadley)

## Housekeeping

* update `pkgdown` site to Bootstrap 5 and related revamp, e.g. reference index and run/show examples (#159 #165 #193, @hadley)
* roxygen updated to use markdown, general cleanup (#160 #161 #191 #201, @hadley)
* testing improvements, e.g. move to `testthat` v3 and snapshots, syntactic sugar (#163 #167 #168 #169 #171 #192, @hadley)
* README tweaks (#162 #176, @hadley)
* modernize GitHub Actions (#171, @hadley)
* drop support for R versions below 4.0.0 (#177, @hadley)
* internal function tweaks (#181 #187 #197, @hadley)
* restyle sources (#185 #186 #191 #199, @daroczig and @hadley)

# logger 0.3.0 (2024-03-03)

Many unrelated small features, fixes and documentation updates collected over 2+ years.

## New features

* update `log_*` functions to invisibly return the formatted log message and record (#26, @r2evans)
* add `namespace` argument to `log_shiny_input_changes` (#93, @kpagacz)
* optionally suppress messages in `globalCallingHandlers` after being logged (#100, @DanChaltiel)
* `as.loglevel` helper to convert string/number to loglevel (requested by @tentacles-from-outer-space)
* new formatter function: `formatter_glue_safe` (#126, @terashim)
* support `OFF` log level (#138, @pawelru)
* override default `INFO` log level via env var (#145, requested by sellorm)

## Fixes

* handle zero-length messages in `formatter_glue_or_sprintf` (#74, @deeenes)
* generalize `log_separator` to work with all layout functions (#96, @Polkas)
* support log levels in `log_shiny_input_changes` (#103, @taekeharkema)
* fix fn name lookup/reference with nested calls (#120, reported by @averissimo)
* force the `file` argument of `appender_tee` (#124, reported by @dbontemps)
* don't allow stacking logger hooks on messages/warnings/errors (reported by @jkeuskamp)
* improve fragile test case when `Hmisc` loaded (#131, @r2evans)
* pass `index`, `namespace` etc from `log_` functions down to `log_level` (#143, @MichaelChirico)
* refer to the caller function in global message logger hooks (#146, reported by @gabesolomon10)

# logger 0.2.2 (2021-10-10)

Maintenance release:

* fix unbalanced code chunk delimiters in vignette (yihui/knitr#2057)

# logger 0.2.1 (2021-07-06)

Maintenance release:

* update `appender_slack` to use `slackr_msg` instead of `text_slackr`

# logger 0.2.0 (2021-03-03)

## Breaking changes

* `appender_console` writes to `stderr` by default instead of `stdout` (#28)

## Fixes

* default date format in `glue` layouts (#44, @burgikukac)
* `fn` reference in loggers will not to a Cartesian join on the log lines and message, but merge (and clean up) the `fn` even for large anonymous functions (#20)

## New features

* allow defining the log level threshold as a string (#13, @artemklevtsov)
* allow updating the log level threshold, formatter, layout and appender in all namespaces with a single call (#50)
* new argument to `appender_file` to optionally truncate before appending (#24, @eddelbuettel)
* new arguments to `appender_file` to optionally rotate the log files after appending (#42)
* new meta variables for logging in custom layouts: R version and calling package's version
* improved performance by not evaluating arguments when the log record does not meet the log level threshold (#27, @jozefhajnala)
* `logger` in now part of the Mikata Project: https://mikata.dev

## New helper functions

* `%except%`: evaluate an expression with fallback
* `log_separator`: logging with separator lines (#16)
* `log_tictoc`: tic-toc logging (#16, @nfultz)
* `log_failure`: log error before failing (#19, @amy17519)
* `log_messages`, `log_warnings`, `log_errors`: optionally auto-log messages, warnings and errors using `globalCallingHandlers` on R 4.0.0 and above, and injecting `logger` calls to `message`, `warnings` and `stop` below R 4.0.0
* `log_shiny_input_changes`: auto-log input changes in Shiny apps (#25)

## New formatter functions

* `layout_pander`: transform R objects into markdown before logging (#22)

## New layout functions

* `layout_blank`: blank log messages without any modification
* `layout_json_parser`: render the layout as a JSON blob after merging with requested meta fields

## New appender functions

* `appender_telegram`: deliver log records to Telegram (#14, @artemklevtsov)
* `appender_syslog`: deliver log records to syslog (#30, @atheriel)
* `appender_kinesis`: deliver log records to Amazon Kinesis (#35)
* `appender_async`: wrapper function for other appender functions to deliver log records in a background process asynchronously without blocking the master process (#35)

# logger 0.1 (2018-12-20)

Initial CRAN release after collecting feedback for a month on Twitter at `https://twitter.com/daroczig/status/1067461632677330944`:

* finalized design of a log request defined by

    * a log level `threshold`,
    * a `formatter` function preparing the log message,
    * a `layout` function rendering the actual log records and
    * an `appender` function delivering to the log destination

* detailed documentation with 7 vignettes and a lot of examples, even some benchmarks
* ~75% code coverage for unit tests
* 5 `formatter` functions mostly using `paste`, `sprintf` and `glue`
* 6 `layout` functions with convenient wrappers to let users define custom layouts via `glue` or `JSON`, including colorized output
* 5 `appender` functions delivering log records to the console, files, Pushbullet and Slack
* helper function to evaluate an expressions with auto-logging both the expression and its result
* helper function to temporarily update the log level threshold
* helper function to skip running the formatter function on a log message
* mostly backward compatibly with the `logging` and `futile.logger` packages
