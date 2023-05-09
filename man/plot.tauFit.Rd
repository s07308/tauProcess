% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.tauFit.R
\name{plot.tauFit}
\alias{plot.tauFit}
\title{Plot the Tau Process}
\usage{
\method{plot}{tauFit}(x, ...)
}
\arguments{
\item{x}{an object of class "tauFit", returned by \code{tau.fit} function}

\item{...}{additional arguments passed to underlying plot method}
}
\value{
a list with components \code{x} and \code{y}.
}
\description{
This function plot the estimated tau process obtained from \code{tau.fit}.
It can be used to monitor the progression of treatment effect.
}
\examples{
fit <- tau.fit(data = pbc)
plot(fit)
}