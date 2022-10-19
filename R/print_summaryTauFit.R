#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
print.summaryTauFit <- function(x) {
  cat(" N0=", x$N0, " N1=", x$N1, " The truncation time is specified as", x$t, "\n")
  cat("\n")
  cat("Random grouping design:\n")
  stats::printCoefmat(x$tau.fit.r, digits = 3, signif.legend = FALSE)
  cat("\n")
  cat("Fixed grouping design:\n")
  stats::printCoefmat(x$tau.fit.f, digits = 3)
  cat("\n")
  print(x$conf.int, digits = 3)
}
