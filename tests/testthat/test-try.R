test_that('%except% logs errors and returns default value', {
  local_test_logger(layout = layout_glue_generator("{level} {msg}"))
  
  expect_snapshot(out <- FunDoesNotExist(1:10) %except% 1)
  expect_equal(out, 1)
})

test_that("%except% returns value when no error", {
  expect_equal(5 %except% 1, 5)
})
