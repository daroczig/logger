everything <- 42
g <- function() {
    log_info("Hi {everything}")
}
f <- function() {
    log_info("Hi %s", everything)
}

test_that('glue works', {
    local_test_logger(formatter = formatter_glue)

    expect_equal(formatter_glue("Hi"), "Hi")
    expect_equal(formatter_glue("   Hi"), "   Hi")
    expect_equal(formatter_glue('1 + {1}'), '1 + 1')
    expect_equal(formatter_glue('{1:2}'), as.character(1:2))
    expect_equal(formatter_glue('pi is {round(pi, 2)}'), 'pi is 3.14')
    expect_equal(formatter_glue("Hi {42}"), "Hi 42")
    expect_equal(formatter_glue("Hi {a}", a = 42), "Hi 42")
    expect_equal(formatter_glue("Hi {everything}"), "Hi 42")
    expect_equal(formatter_glue("Hi {1:2}"), paste("Hi", 1:2))

    expect_output(log_info("Hi {everything}"), '42')
    expect_output(log_warn("Hi {everything}"), '42')
    expect_output(g(), '42')

    local_test_logger(
        formatter = formatter_glue,
        appender = appender_void,
    )
    expect_error(formatter_glue('malformed {'))
    expect_error(formatter_glue('malformed {{'), NA)

    ## disabled for https://github.com/atalv/azlogr/issues/35
    ## expect_warning(formatter_glue(NULL))
    ## expect_warning(log_info(NULL))
    ## expect_warning(log_info(a = 42, b = "foobar"))
})

test_that("glue gives informative error if message contains curlies", {
    local_test_logger(formatter = formatter_glue)
    expect_snapshot(log_info("hi{"), error = TRUE)
})

test_that('glue_safe works', {
    local_test_logger(formatter = formatter_glue_safe)

    expect_equal(formatter_glue_safe("Hi"), "Hi")
    expect_equal(formatter_glue_safe("   Hi"), "   Hi")
    expect_equal(formatter_glue_safe("Hi {a}", a = 42), "Hi 42")
    expect_equal(formatter_glue_safe("Hi {everything}"), "Hi 42")

    expect_output(log_info("Hi {everything}"), '42')
    expect_output(log_warn("Hi {everything}"), '42')
    expect_output(g(), '42')

    expect_error(formatter_glue_safe("Hi {42}"))
    expect_error(formatter_glue_safe('malformed {'))
    expect_error(formatter_glue_safe('malformed {{'), NA)

})

test_that('sprintf works', {
    local_test_logger(formatter = formatter_sprintf)

    expect_equal(formatter_sprintf("Hi"), "Hi")
    expect_equal(formatter_sprintf("Hi %s", 42), "Hi 42")
    expect_equal(formatter_sprintf("Hi %s", everything), "Hi 42")
    expect_equal(formatter_sprintf("Hi %s", 1:2), paste("Hi", 1:2))
    expect_equal(formatter_sprintf('1 + %s', 1), '1 + 1')
    expect_equal(formatter_sprintf('=>%2i', 2), '=> 2')
    expect_equal(formatter_sprintf('%s', 1:2), as.character(1:2))
    expect_equal(formatter_sprintf('pi is %s', round(pi, 2)), 'pi is 3.14')
    expect_equal(formatter_sprintf('pi is %1.2f', pi), 'pi is 3.14')

    expect_error(formatter_sprintf('%s and %i', 1))
    expect_equal(formatter_sprintf('%s and %i', 1, 2), '1 and 2')

    expect_output(log_info("Hi %s", everything), '42')
    expect_output(f(), '42')

})


result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?")

test_that('glue+sprintf works', {

    expect_equal(formatter_glue_or_sprintf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
    expect_equal(formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
    expect_equal(formatter_glue_or_sprintf("Hi {c('foo', 'bar')}, did you know that 2*4=%s?", 2*4), result)
    expect_equal(formatter_glue_or_sprintf("Hi %s, did you know that 2*4={2*4}?", c('foo', 'bar')), result)
    expect_equal(formatter_glue_or_sprintf("Hi %s, did you know that 2*4=%s?", c('foo', 'bar'), 2*4), result)

    expect_equal(formatter_glue_or_sprintf('%s and %i'), '%s and %i')
    expect_equal(formatter_glue_or_sprintf('%s and %i', 1), '%s and %i')
    expect_equal(formatter_glue_or_sprintf('fun{fun}'), 'fun{fun}')

    for (fn in c(formatter_sprintf, formatter_glue_or_sprintf)) {
        local_test_logger(formatter = fn, appender = appender_void) 
        expect_error(log_info(character(0)), NA)

        local_test_logger(formatter = fn)
        expect_output(log_info(character(0)), 'INFO')
    }

})

test_that('formatter_logging works', {
    local_test_logger(formatter = formatter_logging)

    expect_output(log_info('42'), '42')
    expect_output(log_info(42), '42')
    expect_output(log_info(4+2), '4 \\+ 2')
    expect_output(log_info(4+2), '6')
    expect_output(log_info('foo %s', 'bar'), 'foo bar')
    expect_output(log_info(12, 100+100, 2*2), '12')
    expect_output(log_info(12, 100+100, 2*2), '100 \\+ 100')
    expect_output(log_info(12, 100+100, 2*2), '200')
    expect_output(log_info(12, 100+100, 2*2), '2 \\* 2')
    expect_output(log_info(12, 100+100, 2*2), '4')

})

test_that('special chars in the text work', {
  expect_equal(formatter_glue('JSON: {jsonlite::toJSON(1:4)}'), 'JSON: [1,2,3,4]')
  expect_equal(formatter_glue('JSON: {jsonlite::toJSON(iris[1:2, ], auto_unbox = TRUE)}'), 'JSON: [{"Sepal.Length":5.1,"Sepal.Width":3.5,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":4.9,"Sepal.Width":3,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"}]') # nolint
    
  local_test_logger()
  expect_output(log_info('JSON: {jsonlite::toJSON(1:4)}'), '[1,2,3,4]')
  expect_output(log_info('JSON: {jsonlite::toJSON(iris[1:2, ], auto_unbox = TRUE)}'), '[{"Sepal.Length":5.1,"Sepal.Width":3.5,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":4.9,"Sepal.Width":3,"Petal.Length":1.4,"Petal.Width":0.2,"Species":"setosa"}]') # nolint
})

test_that('pander formatter', {
    local_test_logger(formatter = formatter_pander)
    # pander partially matches coef to coefficient
    withr::local_options(warnPartialMatchDollar = FALSE)
    
    expect_output(log_info(42), '_42_')
    expect_output(log_info('42'), '42')
    expect_output(log_info(head(iris)), 'Sepal.Length')
    expect_output(log_info(lm(hp ~ wt, mtcars)), 'Fitting linear model')
})

## cleanup
rm(everything)
rm(f)

test_that('paste formatter in actual logs', {
    local_test_logger(formatter = formatter_paste)
    expect_output(log_info('hi', 5), 'hi 5')
})

test_that('skip formatter', {
    local_test_logger(formatter = formatter_glue)
   expect_output(log_info(skip_formatter('hi {pi}')), 'hi \\{pi\\}')
    expect_error(log_info(skip_formatter(mtcars)))
    expect_error(log_info(skip_formatter('hi {x}', x = 4)))
})

test_that('skip formatter', {
    local_test_logger(formatter = formatter_json)
    expect_output(log_info(skip_formatter('hi {pi}')), 'hi \\{pi\\}')
    expect_output(log_info(x = 1), '\\{"x":1\\}')
})
