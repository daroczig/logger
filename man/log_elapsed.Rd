% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers.R
\name{log_elapsed}
\alias{log_elapsed}
\alias{log_elapsed_start}
\title{Log cumulative running time}
\usage{
log_elapsed(..., level = INFO, namespace = NA_character_)

log_elapsed_start(level = INFO, namespace = NA_character_, quiet = FALSE)
}
\arguments{
\item{...}{passed to \code{\link[=log_level]{log_level()}}}

\item{level}{see \code{\link[=log_levels]{log_levels()}}}

\item{namespace}{x}

\item{quiet}{Should starting the time emit a log message}
}
\description{
This function is working like \code{\link[=log_tictoc]{log_tictoc()}} but differs in that it continues
to count up rather than resetting the timer at every call. You can set the
start time using \code{log_elapsed_start()}, but if that hasn't been called it
will show the time since the R session started.
}
\examples{
log_elapsed_start()
Sys.sleep(0.4)
log_elapsed("Tast 1")
Sys.sleep(0.2)
log_elapsed("Task 2")

}
