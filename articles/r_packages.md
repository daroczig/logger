# Logging from R Packages

In this vignette I suppose that you are already familiar with
[Customizing the format and destination of log
records](https://daroczig.github.io/logger/articles/customize_logger.html)
vignette, especially with the [Log
namespaces](https://daroczig.github.io/logger/articles/customize_logger.html#log-namespaces)
section.

So that your R package’s users can suppress (or render with custom
layout) the log messages triggered by your R package, it’s wise to
record all those log messages in a custom namespace. By default, if you
are calling the
[`?log_level`](https://daroczig.github.io/logger/reference/log_level.md)
function family from an R package after importing from the `logger`
package, then `logger` will try to auto-guess the calling R package name
and use that as the default namespace, see eg:

``` r
library(logger)
devtools::load_all(system.file("demo-packages/logger-tester-package", package = "logger"))
#> ℹ Loading logger.tester
logger_tester_function(INFO, "hi from tester package")
#> INFO [2026-01-06 21:43:30] hi from tester package 0.0807501375675201
```

But if auto-guessing is not your style, then feel free to set your
custom namespace (eg the name of your package) in all
[`?log_info`](https://daroczig.github.io/logger/reference/log_level.md)
etc function calls and let your users know about how to suppress /
reformat / redirect your log messages via
[`?log_threshold`](https://daroczig.github.io/logger/reference/log_threshold.md),
[`?log_layout`](https://daroczig.github.io/logger/reference/log_layout.md),
[`?log_appender`](https://daroczig.github.io/logger/reference/log_appender.md).

Please note that setting the formatter function via
[`?log_formatter`](https://daroczig.github.io/logger/reference/log_formatter.md)
should not be left to the R package end-users, as the log message
formatter is specific to your logging calls, so that should be decided
by the R package author. Feel free to pick any formatter function (eg
`glue`, `sprintf`, `paste` or something else), and set that via
[`?log_formatter`](https://daroczig.github.io/logger/reference/log_formatter.md)
when your R package is loaded. All other parameters of your `logger`
will inherit from the `global` namespace – set by your R package’s end
user.
