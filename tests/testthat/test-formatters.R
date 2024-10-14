test_that("glue works", {
  local_test_logger(formatter = formatter_glue)
  a <- 43

  expect_equal(formatter_glue("Hi"), "Hi")
  expect_equal(formatter_glue("   Hi"), "   Hi")
  expect_equal(formatter_glue("1 + {1}"), "1 + 1")
  expect_equal(formatter_glue("{1:2}"), as.character(1:2))
  expect_equal(formatter_glue("pi is {round(pi, 2)}"), "pi is 3.14")
  expect_equal(formatter_glue("Hi {42}"), "Hi 42")
  expect_equal(formatter_glue("Hi {a}", a = 42), "Hi 42")
  expect_equal(formatter_glue("Hi {1:2}"), paste("Hi", 1:2))

  expect_output(do.call(logger, namespaces$global[[1]])(INFO, 42), "42")
  expect_output(do.call(logger, namespaces$global[[1]])(INFO, "Hi {a}"), "43")

  expect_equal(formatter_glue("Hi {a}"), "Hi 43")
  expect_output(log_info("Hi {a}"), "43")
  expect_output(log_warn("Hi {a}"), "43")
  f <- function() log_info("Hi {a}")
  expect_output(f(), "43")

  local_test_logger(
    formatter = formatter_glue,
    appender = appender_void,
  )
  expect_snapshot(formatter_glue("malformed {"), error = TRUE)
  expect_no_error(formatter_glue("malformed {{"))

  ## nolint start
  ## disabled for https://github.com/atalv/azlogr/issues/35
  ## expect_warning(formatter_glue(NULL))
  ## expect_warning(log_info(NULL))
  ## expect_warning(log_info(a = 42, b = "foobar"))
  ## nolint end
})

test_that("glue gives informative error if message contains curlies", {
  local_test_logger(formatter = formatter_glue)
  expect_snapshot(log_info("hi{"), error = TRUE)
})

test_that("glue_safe works", {
  local_test_logger(formatter = formatter_glue_safe)

  expect_equal(formatter_glue_safe("Hi"), "Hi")
  expect_equal(formatter_glue_safe("   Hi"), "   Hi")
  expect_equal(formatter_glue_safe("Hi {a}", a = 42), "Hi 42")

  a <- 43
  expect_equal(formatter_glue_safe("Hi {a}"), "Hi 43")
  expect_output(log_info("Hi {a}"), "43")
  expect_output(log_warn("Hi {a}"), "43")
  f <- function() log_info("Hi {a}")
  expect_output(f(), "43")

  expect_snapshot(error = TRUE, {
    formatter_glue_safe("Hi {42}")
    formatter_glue_safe("malformed {")
  })
  expect_no_error(formatter_glue_safe("malformed {{"))
})

test_that("sprintf works", {
  local_test_logger(formatter = formatter_sprintf)

  expect_equal(formatter_sprintf("Hi"), "Hi")
  expect_equal(formatter_sprintf("Hi %s", 42), "Hi 42")
  expect_equal(formatter_sprintf("Hi %s", 1:2), paste("Hi", 1:2))
  expect_equal(formatter_sprintf("1 + %s", 1), "1 + 1")
  expect_equal(formatter_sprintf("=>%2i", 2), "=> 2")
  expect_equal(formatter_sprintf("%s", 1:2), as.character(1:2))
  expect_equal(formatter_sprintf("pi is %s", round(pi, 2)), "pi is 3.14")
  expect_equal(formatter_sprintf("pi is %1.2f", pi), "pi is 3.14")

  expect_snapshot(formatter_sprintf("%s and %i", 1), error = TRUE)
  expect_equal(formatter_sprintf("%s and %i", 1, 2), "1 and 2")

  a <- 43
  expect_output(log_info("Hi %s", a), "43")
  expect_equal(formatter_sprintf("Hi %s", a), "Hi 43")
  f <- function() log_info("Hi %s", a)
  expect_output(f(), "43")
})


test_that("glue+sprintf works", {
  result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?"
  )

  expect_equal(formatter_glue_or_sprintf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
  expect_equal(formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
  expect_equal(formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4=%s?", 2 * 4), result)
  expect_equal(formatter_glue_or_sprintf("Hi %s, did you know that 2*4={2*4}?", c("foo", "bar")), result)
  expect_equal(formatter_glue_or_sprintf("Hi %s, did you know that 2*4=%s?", c("foo", "bar"), 2 * 4), result)

  expect_equal(formatter_glue_or_sprintf("%s and %i"), "%s and %i")
  expect_equal(formatter_glue_or_sprintf("%s and %i", 1), "%s and %i")
  expect_equal(formatter_glue_or_sprintf("fun{fun}"), "fun{fun}")

  for (fn in c(formatter_sprintf, formatter_glue_or_sprintf)) {
    local_test_logger(formatter = fn, appender = appender_void)
    expect_no_error(log_info(character(0)))

    local_test_logger(formatter = fn)
    expect_output(log_info(character(0)), "INFO")
  }
})

test_that("formatter_logging works", {
  local_test_logger(formatter = formatter_logging)

  expect_output(log_info("42"), "42")
  expect_output(log_info(42), "42")
  expect_output(log_info(4 + 2), "4 \\+ 2")
  expect_output(log_info(4 + 2), "6")
  expect_output(log_info("foo %s", "bar"), "foo bar")
  expect_output(log_info(12, 100 + 100, 2 * 2), "12")
  expect_output(log_info(12, 100 + 100, 2 * 2), "100 \\+ 100")
  expect_output(log_info(12, 100 + 100, 2 * 2), "200")
  expect_output(log_info(12, 100 + 100, 2 * 2), "2 \\* 2")
  expect_output(log_info(12, 100 + 100, 2 * 2), "4")
})

test_that("special chars in the text work", {
  array <- "[1, 2, 3, 4]"
  object <- '{"x": 1, "y": 2}'
  expect_equal(formatter_glue("JSON: {array}"), paste0("JSON: ", array))
  expect_equal(formatter_glue("JSON: {object}"), paste0("JSON: ", object))

  local_test_logger()
  expect_output(log_info("JSON: {array}"), paste0("JSON: ", array), fixed = TRUE)
  expect_output(log_info("JSON: {object}"), paste0("JSON: ", object), fixed = TRUE)
})

test_that("pander formatter", {
  local_test_logger(formatter = formatter_pander)
  # pander partially matches coef to coefficient
  withr::local_options(warnPartialMatchDollar = FALSE)

  expect_output(log_info(42), "_42_")
  expect_output(log_info("42"), "42")
  expect_output(log_info(head(iris)), "Sepal.Length")
  expect_output(log_info(lm(hp ~ wt, mtcars)), "Fitting linear model")
})

test_that("paste formatter in actual logs", {
  local_test_logger(formatter = formatter_paste)
  expect_output(log_info("hi", 5), "hi 5")
})

test_that("skip formatter", {
  local_test_logger(formatter = formatter_glue)
  expect_output(log_info(skip_formatter("hi {pi}")), "hi \\{pi\\}")
  expect_snapshot(log_info(skip_formatter("hi {x}", x = 4)), error = TRUE)
})

test_that("skip formatter", {
  local_test_logger(formatter = formatter_json)
  expect_output(log_info(skip_formatter("hi {pi}")), "hi \\{pi\\}")
  expect_output(log_info(x = 1), '\\{"x":1\\}')
})
