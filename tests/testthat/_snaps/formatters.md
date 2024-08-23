# glue gives informative error if message contains curlies

    Code
      log_info("hi{")
    Condition
      Error in `formatter_glue()`:
      ! `glue()` failed.
      i For strings containing `{`/`}` consider using`skip_formatter()` or another `log_formatter`
      Caused by error in `glue_data()`:
      ! Expecting '}'

---

    Code
      log_info("hi{")
    Condition
      Error:
      ! `glue()` failed in `formatter_glue()` on:
      
      glue::glue(..., .envir = .topenv)
      
      Raw error message:
      
      Expecting '}'
      
      For strings containing `{`/`}` consider using`skip_formatter()` or another `log_formatter`

