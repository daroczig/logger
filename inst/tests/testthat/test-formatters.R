library(logger)
library(testthat)

context('formatters')
everything <- 42

test_that('glue works', {
    expect_equal(formatter_glue("Hi"), "Hi")
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

})
