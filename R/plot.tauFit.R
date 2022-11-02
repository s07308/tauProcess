#' Plot method for `tauFit` objects
#'
#' @param x an object of class `tauFit`, returned by `tau.fit` function.
#' @param ... additional arguments passed to underlying plot method.
#'
#' @return a list with components `x` and `y`.
#' @export
#'
#' @examples "later"
plot.tauFit <- function(x, ...) {
  xx <- x$t
  yy <- x$tau

  plot(xx, yy, type = "b",
       xlab = "time",
       ylab = "tau(t)",
       main = "tau process")
}
