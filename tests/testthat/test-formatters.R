library(logger)
library(testthat)

## save current settings so that we can reset later
formatter  <- log_formatter()

context('formatters')
everything <- 42
g <- function() {
    log_info("Hi {everything}")
}
f <- function() {
    log_info("Hi %s", everything)
}

log_formatter(formatter_glue)
test_that('glue works', {

    expect_equal(formatter_glue("Hi"), "Hi")
    expect_equal(formatter_glue("   Hi"), "   Hi")
    expect_equal(formatter_glue('1 + {1}'), '1 + 1')
    expect_equal(formatter_glue('{1:2}'), as.character(1:2))
    expect_equal(formatter_glue('pi is {round(pi, 2)}'), 'pi is 3.14')
    expect_equal(formatter_glue("Hi {42}"), "Hi 42")
    expect_equal(formatter_glue("Hi {a}", a = 42), "Hi 42")
    expect_equal(formatter_glue("Hi {everything}"), "Hi 42")
    expect_equal(formatter_glue("Hi {1:2}"), paste("Hi", 1:2))

    expect_output(do.call(logger, logger:::namespaces$global[[1]])(INFO, 42), '42')
    expect_output(do.call(logger, logger:::namespaces$global[[1]])(INFO, "Hi {everything}"), '42')

    expect_output(log_info("Hi {everything}"), '42')
    expect_output(log_warn("Hi {everything}"), '42')
    expect_output(g(), '42')

})

log_formatter(formatter_sprintf)
test_that('sprintf works', {

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

})

test_that('formatter_logging works', {

    log_formatter(formatter_logging)
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

## cleanup
rm(everything)
rm(f)

log_formatter(formatter_paste)
test_that('paste formatter in actual logs', {
    expect_output(log_info('hi', 5), 'hi 5')
})

log_formatter(formatter_glue)
test_that('skip formatter', {
    expect_output(log_info(skip_formatter('hi {pi}')), 'hi \\{pi\\}')
    expect_error(log_info(skip_formatter(mtcars)))
    expect_error(log_info(skip_formatter('hi {x}', x = 4)))
})

log_formatter(formatter)
