library(logger)
library(testthat)

context('formatters')
everything <- 42

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

})

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

})


result <- c(
    "Hi foo, did you know that 2*4=8?",
    "Hi bar, did you know that 2*4=8?")

test_that('glue+sprintf works', {

    expect_equal(formatter_glue_or_sprinf("Hi ", "{c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
    expect_equal(formatter_glue_or_sprinf("Hi {c('foo', 'bar')}, did you know that 2*4={2*4}?"), result)
    expect_equal(formatter_glue_or_sprinf("Hi {c('foo', 'bar')}, did you know that 2*4=%s?", 2*4), result)
    expect_equal(formatter_glue_or_sprinf("Hi %s, did you know that 2*4={2*4}?", c('foo', 'bar')), result)
    expect_equal(formatter_glue_or_sprinf("Hi %s, did you know that 2*4=%s?", c('foo', 'bar'), 2*4), result)

    expect_equal(formatter_glue_or_sprinf('%s and %i'), '%s and %i')
    expect_equal(formatter_glue_or_sprinf('%s and %i', 1), '%s and %i')
    expect_equal(formatter_glue_or_sprinf('fun{fun}'), 'fun{fun}')

})

rm(everything)
