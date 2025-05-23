% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/appenders.R
\name{appender_console}
\alias{appender_console}
\alias{appender_stderr}
\title{Append log record to stderr}
\usage{
appender_console(lines)

appender_stderr(lines)
}
\arguments{
\item{lines}{character vector}
}
\description{
Append log record to stderr
}
\seealso{
Other log_appenders: 
\code{\link{appender_async}()},
\code{\link{appender_file}()},
\code{\link{appender_kinesis}()},
\code{\link{appender_pushbullet}()},
\code{\link{appender_slack}()},
\code{\link{appender_stdout}()},
\code{\link{appender_syslog}()},
\code{\link{appender_tee}()},
\code{\link{appender_telegram}()}
}
\concept{log_appenders}
