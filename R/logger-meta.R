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

  force(.topcall); force(.topenv)
  delayedAssign('fn', deparse_to_one_line(.topcall[[1]]), assign.env = env)
  delayedAssign('call', deparse_to_one_line(.topcall), assign.env = env)
  delayedAssign('topenv', top_env_name(.topenv), assign.env = env)

  env$time <- timestamp
  env$levelr <- log_level
  env$level <- attr(log_level, 'level')

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
  delayedAssign("node", .sysinfo[['nodename']], assign.env = env)
  delayedAssign("arch", .sysinfo[['machine']], assign.env = env)
  delayedAssign("os_name", .sysinfo[['sysname']], assign.env = env)
  delayedAssign("os_release", .sysinfo[['release']], assign.env = env)
  delayedAssign("os_version", .sysinfo[['version']], assign.env = env)
  delayedAssign("user", .sysinfo[['user']], assign.env = env)

  env
}


#' Collect useful information about the logging environment to be used in log messages
#'
#' Available variables to be used in the log formatter functions, eg in [layout_glue_generator()]:
#' \itemize{
#'   \item levelr: log level as an R object, eg [INFO()]
#'   \item level: log level as a string, eg [INFO()]
#'   \item time: current time as `POSIXct`
#'   \item node: name by which the machine is known on the network as reported by `Sys.info`
#'   \item arch: machine type, typically the CPU architecture
#'   \item os_name: Operating System's name
#'   \item os_release: Operating System's release
#'   \item os_version: Operating System's version
#'   \item user: name of the real user id as reported by `Sys.info`
#'   \item pid: the process identification number of the R session
#'   \item node: name by which the machine is known on the network as reported by `Sys.info`
#'   \item r_version: R's major and minor version as a string
#'   \item ns: namespace usually defaults to `global` or the name of the holding R package of the calling the logging function
#'   \item ns_pkg_version: the version of `ns` when it's a package
#'   \item ans: same as `ns` if there's a defined [logger()] for the namespace, otherwise a fallback namespace (eg usually `global`)
#'   \item topenv: the name of the top environment from which the parent call was called (eg R package name or `GlobalEnv`)
#'   \item call: parent call (if any) calling the logging function
#'   \item fn: function's (if any) name calling the logging function
#' }
#' @param log_level log level as per [log_levels()]
#' @inheritParams log_level
#' @return list
#' @export
#' @importFrom utils packageVersion
#' @seealso [layout_glue_generator()]
get_logger_meta_variables <- function(log_level = NULL,
                                      namespace = NA_character_,
                                      .logcall = sys.call(),
                                      .topcall = sys.call(-1),
                                      .topenv = parent.frame()) {

  sysinfo <- Sys.info()
  timestamp <- Sys.time()

  list(
    ns        = namespace,
    ans       = fallback_namespace(namespace),
    topenv    = top_env_name(.topenv),
    fn        = deparse_to_one_line(.topcall[[1]]),
    call      = deparse_to_one_line(.topcall),

    time      = timestamp,
    levelr    = log_level,
    level     = attr(log_level, 'level'),

    pid       = Sys.getpid(),

    ## R and ns package versions
    r_version   = paste0(R.Version()[c('major', 'minor')], collapse = '.'),
    ns_pkg_version = tryCatch(as.character(packageVersion(namespace)), error = function(e) NA_character_),

    ## stuff from Sys.info
    node       = sysinfo[['nodename']],
    arch       = sysinfo[['machine']],
    os_name    = sysinfo[['sysname']],
    os_release = sysinfo[['release']],
    os_version = sysinfo[['version']],
    user       = sysinfo[['user']]
    ## NOTE might be better to rely on the whoami pkg?

    ## TODO jenkins (or any) env vars => no need to get here, users can write custom layouts
    ## TODO seed
  )
}
