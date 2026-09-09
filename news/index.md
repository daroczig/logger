# Changelog

## logger (development version)

- [`log_with_separator()`](https://daroczig.github.io/logger/reference/log_with_separator.md)
  now correctly evaluates in the caller environment, so it behaves as
  expected when wrapped in a function call.
  ([\#245](https://github.com/daroczig/logger/issues/245))

## logger 0.4.3 (2026-08-23)

CRAN release: 2026-08-24

Maintenance release:

- Update `log4r` migration vignette to reflect their new API with
  conflicting function names

## logger 0.4.2 (2026-05-08)

CRAN release: 2026-05-10

Maintenance release:

- Added
  [`appender_ntfy()`](https://daroczig.github.io/logger/reference/appender_ntfy.md)
  to use {ntfy} as an appender
  ([\#240](https://github.com/daroczig/logger/issues/240),
  [@jonocarroll](https://github.com/jonocarroll))
- [`normalizePath()`](https://rdrr.io/r/base/normalizePath.html) in the
  `log_call_location()` no longer triggers warning if the package source
  does not exist
  ([\#241](https://github.com/daroczig/logger/issues/241),
  [@maksymiuks](https://github.com/maksymiuks))
- Fix failing unit test on CRAN

## logger 0.4.1 (2025-09-08)

CRAN release: 2025-09-11

New features and quality of life improvements:

- Support renaming meta fields
  ([\#217](https://github.com/daroczig/logger/issues/217),
  [@atusy](https://github.com/atusy))
- Added
  [`log_elapsed()`](https://daroczig.github.io/logger/reference/log_elapsed.md)
  to show cumulative elapsed running time
  ([\#221](https://github.com/daroczig/logger/issues/221),
  [@thomasp85](https://github.com/thomasp85))
- [`log_errors()`](https://daroczig.github.io/logger/reference/log_errors.md)
  gains a `traceback` argument that toggles whether the error traceback
  should be logged along with the message (fix
  [\#86](https://github.com/daroczig/logger/issues/86) via
  [\#223](https://github.com/daroczig/logger/issues/223),
  [@thomasp85](https://github.com/thomasp85))
- File and line location of the log call is now available to the layouts
  (fix [\#110](https://github.com/daroczig/logger/issues/110) via
  [\#224](https://github.com/daroczig/logger/issues/224),
  [@thomasp85](https://github.com/thomasp85))
- New
  [`formatter_cli()`](https://daroczig.github.io/logger/reference/formatter_cli.md)
  allows you to use the syntax from the cli package to create log
  messages (fix [\#210](https://github.com/daroczig/logger/issues/210)
  via [\#225](https://github.com/daroczig/logger/issues/225),
  [@thomasp85](https://github.com/thomasp85))
- New
  [`log_chunk_time()`](https://daroczig.github.io/logger/reference/log_chunk_time.md)
  helper function to automatically log the execution time of knitr code
  chunks (fix [\#222](https://github.com/daroczig/logger/issues/222) via
  [\#227](https://github.com/daroczig/logger/issues/227),
  [@thomasp85](https://github.com/thomasp85))
- Allow user to overwrite the timestamp during logging if needed (fix
  [\#230](https://github.com/daroczig/logger/issues/230),
  [@thomasp85](https://github.com/thomasp85))

## logger 0.4.0 (2024-10-19)

CRAN release: 2024-10-22

A lot of internal code quality improvements and standardization,
improved documentations, modernized tests, performance speedups.

### New features

- logo 😻 ([\#196](https://github.com/daroczig/logger/issues/196),
  [@hadley](https://github.com/hadley))
- computing metadata lazily, so various expensive computations are only
  performed if you actually add them to the log
  ([\#105](https://github.com/daroczig/logger/issues/105),
  [@hadley](https://github.com/hadley))
- [`log_appender()`](https://daroczig.github.io/logger/reference/log_appender.md),
  [`log_layout()`](https://daroczig.github.io/logger/reference/log_layout.md)
  and
  [`log_formatter()`](https://daroczig.github.io/logger/reference/log_formatter.md)
  now check that you are calling them with a function, and return the
  previously set value
  ([\#170](https://github.com/daroczig/logger/issues/170),
  [@hadley](https://github.com/hadley))
- new function to return number of log indices
  ([\#194](https://github.com/daroczig/logger/issues/194),
  [@WurmPeter](https://github.com/WurmPeter))
- `appender_async` is now using `mirai` instead of a custom background
  process and queue system
  ([\#214](https://github.com/daroczig/logger/issues/214),
  [@hadley](https://github.com/hadley)
  [@shikokuchuo](https://github.com/shikokuchuo))
- [`layout_gha()`](https://daroczig.github.io/logger/reference/layout_gha.md)
  for providing native GitHub Action logging. This automatically gets
  used when running code in github actions
  ([@thomasp85](https://github.com/thomasp85))

### Fixes

- `eval` scoping and lazy eval
  ([\#178](https://github.com/daroczig/logger/issues/178),
  [@hadley](https://github.com/hadley))

### Housekeeping

- update `pkgdown` site to Bootstrap 5 and related revamp,
  e.g. reference index and run/show examples
  ([\#159](https://github.com/daroczig/logger/issues/159)
  [\#165](https://github.com/daroczig/logger/issues/165)
  [\#193](https://github.com/daroczig/logger/issues/193),
  [@hadley](https://github.com/hadley))
- roxygen updated to use markdown, general cleanup
  ([\#160](https://github.com/daroczig/logger/issues/160)
  [\#161](https://github.com/daroczig/logger/issues/161)
  [\#191](https://github.com/daroczig/logger/issues/191)
  [\#201](https://github.com/daroczig/logger/issues/201),
  [@hadley](https://github.com/hadley))
- testing improvements, e.g. move to `testthat` v3 and snapshots,
  syntactic sugar
  ([\#163](https://github.com/daroczig/logger/issues/163)
  [\#167](https://github.com/daroczig/logger/issues/167)
  [\#168](https://github.com/daroczig/logger/issues/168)
  [\#169](https://github.com/daroczig/logger/issues/169)
  [\#171](https://github.com/daroczig/logger/issues/171)
  [\#192](https://github.com/daroczig/logger/issues/192),
  [@hadley](https://github.com/hadley))
- README tweaks ([\#162](https://github.com/daroczig/logger/issues/162)
  [\#176](https://github.com/daroczig/logger/issues/176),
  [@hadley](https://github.com/hadley))
- modernize GitHub Actions
  ([\#171](https://github.com/daroczig/logger/issues/171),
  [@hadley](https://github.com/hadley))
- drop support for R versions below 4.0.0
  ([\#177](https://github.com/daroczig/logger/issues/177),
  [@hadley](https://github.com/hadley))
- internal function tweaks
  ([\#181](https://github.com/daroczig/logger/issues/181)
  [\#187](https://github.com/daroczig/logger/issues/187)
  [\#197](https://github.com/daroczig/logger/issues/197),
  [@hadley](https://github.com/hadley))
- restyle sources
  ([\#185](https://github.com/daroczig/logger/issues/185)
  [\#186](https://github.com/daroczig/logger/issues/186)
  [\#191](https://github.com/daroczig/logger/issues/191)
  [\#199](https://github.com/daroczig/logger/issues/199),
  [@daroczig](https://github.com/daroczig) and
  [@hadley](https://github.com/hadley))

## logger 0.3.0 (2024-03-03)

CRAN release: 2024-03-05

Many unrelated small features, fixes and documentation updates collected
over 2+ years.

### New features

- update `log_*` functions to invisibly return the formatted log message
  and record ([\#26](https://github.com/daroczig/logger/issues/26),
  [@r2evans](https://github.com/r2evans))
- add `namespace` argument to `log_shiny_input_changes`
  ([\#93](https://github.com/daroczig/logger/issues/93),
  [@kpagacz](https://github.com/kpagacz))
- optionally suppress messages in `globalCallingHandlers` after being
  logged ([\#100](https://github.com/daroczig/logger/issues/100),
  [@DanChaltiel](https://github.com/DanChaltiel))
- `as.loglevel` helper to convert string/number to loglevel (requested
  by
  [@tentacles-from-outer-space](https://github.com/tentacles-from-outer-space))
- new formatter function: `formatter_glue_safe`
  ([\#126](https://github.com/daroczig/logger/issues/126),
  [@terashim](https://github.com/terashim))
- support `OFF` log level
  ([\#138](https://github.com/daroczig/logger/issues/138),
  [@pawelru](https://github.com/pawelru))
- override default `INFO` log level via env var
  ([\#145](https://github.com/daroczig/logger/issues/145), requested by
  sellorm)

### Fixes

- handle zero-length messages in `formatter_glue_or_sprintf`
  ([\#74](https://github.com/daroczig/logger/issues/74),
  [@deeenes](https://github.com/deeenes))
- generalize `log_separator` to work with all layout functions
  ([\#96](https://github.com/daroczig/logger/issues/96),
  [@Polkas](https://github.com/Polkas))
- support log levels in `log_shiny_input_changes`
  ([\#103](https://github.com/daroczig/logger/issues/103),
  [@taekeharkema](https://github.com/taekeharkema))
- fix fn name lookup/reference with nested calls
  ([\#120](https://github.com/daroczig/logger/issues/120), reported by
  [@averissimo](https://github.com/averissimo))
- force the `file` argument of `appender_tee`
  ([\#124](https://github.com/daroczig/logger/issues/124), reported by
  [@dbontemps](https://github.com/dbontemps))
- don’t allow stacking logger hooks on messages/warnings/errors
  (reported by [@jkeuskamp](https://github.com/jkeuskamp))
- improve fragile test case when `Hmisc` loaded
  ([\#131](https://github.com/daroczig/logger/issues/131),
  [@r2evans](https://github.com/r2evans))
- pass `index`, `namespace` etc from `log_` functions down to
  `log_level` ([\#143](https://github.com/daroczig/logger/issues/143),
  [@MichaelChirico](https://github.com/MichaelChirico))
- refer to the caller function in global message logger hooks
  ([\#146](https://github.com/daroczig/logger/issues/146), reported by
  [@gabesolomon10](https://github.com/gabesolomon10))

## logger 0.2.2 (2021-10-10)

CRAN release: 2021-10-19

Maintenance release:

- fix unbalanced code chunk delimiters in vignette (yihui/knitr#2057)

## logger 0.2.1 (2021-07-06)

CRAN release: 2021-07-06

Maintenance release:

- update `appender_slack` to use `slackr_msg` instead of `text_slackr`

## logger 0.2.0 (2021-03-03)

CRAN release: 2021-03-04

### Breaking changes

- `appender_console` writes to `stderr` by default instead of `stdout`
  ([\#28](https://github.com/daroczig/logger/issues/28))

### Fixes

- default date format in `glue` layouts
  ([\#44](https://github.com/daroczig/logger/issues/44),
  [@burgikukac](https://github.com/burgikukac))
- `fn` reference in loggers will not to a Cartesian join on the log
  lines and message, but merge (and clean up) the `fn` even for large
  anonymous functions
  ([\#20](https://github.com/daroczig/logger/issues/20))

### New features

- allow defining the log level threshold as a string
  ([\#13](https://github.com/daroczig/logger/issues/13),
  [@artemklevtsov](https://github.com/artemklevtsov))
- allow updating the log level threshold, formatter, layout and appender
  in all namespaces with a single call
  ([\#50](https://github.com/daroczig/logger/issues/50))
- new argument to `appender_file` to optionally truncate before
  appending ([\#24](https://github.com/daroczig/logger/issues/24),
  [@eddelbuettel](https://github.com/eddelbuettel))
- new arguments to `appender_file` to optionally rotate the log files
  after appending ([\#42](https://github.com/daroczig/logger/issues/42))
- new meta variables for logging in custom layouts: R version and
  calling package’s version
- improved performance by not evaluating arguments when the log record
  does not meet the log level threshold
  ([\#27](https://github.com/daroczig/logger/issues/27),
  [@jozefhajnala](https://github.com/jozefhajnala))
- `logger` in now part of the Mikata Project: <https://mikata.dev>

### New helper functions

- `%except%`: evaluate an expression with fallback
- `log_separator`: logging with separator lines
  ([\#16](https://github.com/daroczig/logger/issues/16))
- `log_tictoc`: tic-toc logging
  ([\#16](https://github.com/daroczig/logger/issues/16),
  [@nfultz](https://github.com/nfultz))
- `log_failure`: log error before failing
  ([\#19](https://github.com/daroczig/logger/issues/19),
  [@amy17519](https://github.com/amy17519))
- `log_messages`, `log_warnings`, `log_errors`: optionally auto-log
  messages, warnings and errors using `globalCallingHandlers` on R 4.0.0
  and above, and injecting `logger` calls to `message`, `warnings` and
  `stop` below R 4.0.0
- `log_shiny_input_changes`: auto-log input changes in Shiny apps
  ([\#25](https://github.com/daroczig/logger/issues/25))

### New formatter functions

- `layout_pander`: transform R objects into markdown before logging
  ([\#22](https://github.com/daroczig/logger/issues/22))

### New layout functions

- `layout_blank`: blank log messages without any modification
- `layout_json_parser`: render the layout as a JSON blob after merging
  with requested meta fields

### New appender functions

- `appender_telegram`: deliver log records to Telegram
  ([\#14](https://github.com/daroczig/logger/issues/14),
  [@artemklevtsov](https://github.com/artemklevtsov))
- `appender_syslog`: deliver log records to syslog
  ([\#30](https://github.com/daroczig/logger/issues/30),
  [@atheriel](https://github.com/atheriel))
- `appender_kinesis`: deliver log records to Amazon Kinesis
  ([\#35](https://github.com/daroczig/logger/issues/35))
- `appender_async`: wrapper function for other appender functions to
  deliver log records in a background process asynchronously without
  blocking the master process
  ([\#35](https://github.com/daroczig/logger/issues/35))

## logger 0.1 (2018-12-20)

CRAN release: 2019-01-02

Initial CRAN release after collecting feedback for a month on Twitter at
`https://twitter.com/daroczig/status/1067461632677330944`:

- finalized design of a log request defined by

  - a log level `threshold`,
  - a `formatter` function preparing the log message,
  - a `layout` function rendering the actual log records and
  - an `appender` function delivering to the log destination

- detailed documentation with 7 vignettes and a lot of examples, even
  some benchmarks

- ~75% code coverage for unit tests

- 5 `formatter` functions mostly using `paste`, `sprintf` and `glue`

- 6 `layout` functions with convenient wrappers to let users define
  custom layouts via `glue` or `JSON`, including colorized output

- 5 `appender` functions delivering log records to the console, files,
  Pushbullet and Slack

- helper function to evaluate an expressions with auto-logging both the
  expression and its result

- helper function to temporarily update the log level threshold

- helper function to skip running the formatter function on a log
  message

- mostly backward compatibly with the `logging` and `futile.logger`
  packages
