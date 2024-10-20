# JSON layout warns if you include msg

    Code
      layout <- layout_json(fields = "msg")
    Condition
      Warning in `layout_json()`:
      'msg' is always automatically included

# must throw errors

    Code
      layout_simple(FOOBAR)
    Condition
      Error:
      ! object 'FOOBAR' not found
    Code
      layout_simple(42)
    Condition
      Error in `layout_simple()`:
      ! argument "msg" is missing, with no default
    Code
      layout_simple(msg = "foobar")
    Condition
      Error in `layout_simple()`:
      ! argument "level" is missing, with no default

---

    Code
      layout_glue(FOOBAR)
    Condition
      Error:
      ! object 'FOOBAR' not found
    Code
      layout_glue(42)
    Condition
      Error in `layout_glue()`:
      ! Invalid log level, see ?log_levels
    Code
      layout_glue(msg = "foobar")
    Condition
      Error in `layout_glue()`:
      ! argument "level" is missing, with no default
    Code
      layout_glue(level = 53, msg = "foobar")
    Condition
      Error in `layout_glue()`:
      ! Invalid log level, see ?log_levels

# log_info() captures local info

    Code
      log_info("foobar")
    Output
      logger / global / logger / eval / eval(expr, envir)
    Code
      f()
    Output
      logger / global / logger / f / f()
    Code
      g()
    Output
      logger / global / logger / f / f()

# log_info() captures package info

    Code
      logger_tester_function(INFO, "x = ")
    Output
      logger.tester INFO x =  0.0807501375675201
    Code
      logger_info_tester_function("everything = ")
    Output
      logger.tester INFO everything =  42

