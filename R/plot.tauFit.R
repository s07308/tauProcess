#' Plot Method for "tauFit" Objects
#'
#' @description This function plot the estimated local Kendall's tau process obtained from `tau.fit`.
#' It can be used to monitor the progression of treatment effect.
#' @param x an object of class "tauFit", returned by `tau.fit` function
#' @param ... additional arguments passed to underlying plot method
#'
#' @return a list with components `x` and `y`.
#' @export
#'
#' @examples fit <- tau.fit(data = Inotuzumab)
#' plot(fit)
plot.tauFit <- function(x, ...) {
  xx <- x$t
  yy <- x$tau

  plot(xx, yy, type = "b",
       xlab = "time",
       ylab = "tau(t)",
       main = "tau process")
}
