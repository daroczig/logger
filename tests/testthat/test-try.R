test_that('%except% logs errors and returns default value', {
  local_test_logger(layout = layout_glue_generator("{ns} / {ans} / {topenv} / {fn} / {call}\n{level} {msg}"))
  
  f <- function() {
    FunDoesNotExist(1:10) %except% 1
  }

  expect_snapshot(out <- f())
  expect_equal(out, 1)
})

test_that("%except% returns value when no error", {
  expect_equal(5 %except% 1, 5)
})
