test_that("captures call/environment info", {
  f <- function(...) logger_meta_env()
  env <- f(x = 1)

  # values are computed lazily
  expect_type(substitute(fn, env), "language")
  expect_type(substitute(call, env), "language")

  # and give correct values
  expect_equal(env$fn, "f")
  expect_equal(env$call, "f(x = 1)")
  expect_equal(env$topenv, "logger")
})

test_that("captures namespace info", {
  env <- logger_meta_env(namespace = "testthat")
  expect_equal(env$ns, "testthat")
  expect_equal(env$ans, "global")
  expect_equal(env$ns_pkg_version, as.character(packageVersion("testthat")))
})

test_that("captures other environmental metadata", {
  env <- logger_meta_env()
  expect_equal(env$pid, Sys.getpid())
  expect_equal(env$r_version, as.character(getRversion()))

  sysinfo <- as.list(Sys.info())
  expect_equal(env$node, sysinfo$nodename)
  expect_equal(env$arch, sysinfo$machine)
  expect_equal(env$os_name, sysinfo$sysname)
  expect_equal(env$os_release, sysinfo$release)
  expect_equal(env$os_version, sysinfo$version)
  expect_equal(env$user, sysinfo$user)

  local_test_logger(layout = layout_glue_generator("{location$path}#{location$line}: {msg}"))
  expect_output(test_info(), file.path(getwd(), "helper.R#3: TEST"))
})

test_that("format timestamp", {
  option_global_ns <- list(`logger.format_time` = function(x) format(x, "global %Z", tz = "UTC"))

  # If no namespace-specific option, fallback to global
  expect_equal(
    withr::with_options(
      c(option_global_ns, list(`logger.format_time.foo` = NULL)),
      logger_meta_env(namespace = "foo")$time
    ),
    "global UTC"
  )

  # If namespace-specific option is set, use it
  expect_equal(
    withr::with_options(
      c(
        option_global_ns,
        list(`logger.format_time.foo` = function(x) format(x, "foo %Z", tz = "UTC"))
      ),
      logger_meta_env(namespace = "foo")$time
    ),
    "foo UTC"
  )

  # If both options are unset, keep POSIXct
  expect_equal(
    withr::with_options(
      list(`logger.format_time` = NULL, `logger.format_time.foo` = NULL),
      class(logger_meta_env(namespace = "foo")$time)
    ),
    c("POSIXct", "POSIXt")
  )
})
