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

