logger_meta_env <- function(log_level = NULL,
                            namespace = NA_character_,
                            .logcall = sys.call(),
                            .topcall = sys.call(-1),
                            .topenv = parent.frame(),
                            parent = emptyenv()) {
  timestamp <- Sys.time()

  env <- new.env(parent = parent)
  env$ns <- namespace
  env$ans <- fallback_namespace(namespace)

  force(.topcall)
  force(.topenv)
  delayedAssign("fn", deparse_to_one_line(.topcall[[1]]), assign.env = env)
  delayedAssign("call", deparse_to_one_line(.topcall), assign.env = env)
  delayedAssign("topenv", top_env_name(.topenv), assign.env = env)
  delayedAssign("location", log_call_location(.logcall), assign.env = env)

  format_time <- getOption(
    paste0("logger.format_time.", namespace), # prefer namespace-specific option
    default = getOption(
      "logger.format_time", # fallback to global option
      default = identity # if no options, keep it POSIXct for the backward compatibility
    )
  )
  env$time <- format_time(timestamp)
  env$levelr <- log_level
  env$level <- attr(log_level, "level")

  delayedAssign("pid", Sys.getpid(), assign.env = env)

  # R and ns package versions
  delayedAssign(
    "ns_pkg_version",
    tryCatch(as.character(packageVersion(namespace)), error = function(e) NA_character_),
    assign.env = env
  )
  delayedAssign("r_version", as.character(getRversion()), assign.env = env)

  # stuff from Sys.info
  delayedAssign(".sysinfo", Sys.info())
  delayedAssign("node", .sysinfo[["nodename"]], assign.env = env)
  delayedAssign("arch", .sysinfo[["machine"]], assign.env = env)
  delayedAssign("os_name", .sysinfo[["sysname"]], assign.env = env)
  delayedAssign("os_release", .sysinfo[["release"]], assign.env = env)
  delayedAssign("os_version", .sysinfo[["version"]], assign.env = env)
  delayedAssign("user", .sysinfo[["user"]], assign.env = env)

  env
}
