#' Plot the Tau Process with/without cure fraction
#'
#' @description This function plot the estimated tau process with/withour cure fraction obtained from `tau_proc`.
#' It can be used to monitor the progression of treatment effect (for susceptible subgroups).
#' @param x an object of class "tau_process", returned by `tau_proc` function
#' @param ... additional arguments passed to underlying plot method
#'
#' @return a list with components `x` and `y`.
#' @export
#'
#' @examples fit <- tau_proc(data = pbc)
#' plot(fit)
plot.tau_process <- function(x, ...) {
  xx <- x$t
  yy <- x$vals_tau_proc

  plot(xx, yy,
       xlab = "time",
       ylab = "tau(t)",
       main = "tau process",
       ...)
}
