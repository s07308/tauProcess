#' Summarize the Inference Result of Tau Process at Last Specified Time
#'
#' @description This function summarizes the inference results obtained from `tau.fit`.
#' The results under random grouping design (complete randomization design) and fixed grouping design (random allocation rule / urn model) would be almost the same with large sample size.
#' @param object an object of class "tauFit"
#' @param conf.int the significance level of the confidence interval
#' @param ... additional arguments passed to underlying summary method
#'
#' @return an object of class "summaryTauFit"
#' @export
#'
#' @examples fit <- tau.fit(data = pbc)
#' summary(fit)
summary.tauFit <- function(object, conf.int = 0.95, ...) {
  tau.fit <- object
  tau <- tau.fit$tau[[length(tau.fit$t)]]
  se.r <- sqrt(tau.fit$var.r)
  se.f <- sqrt(tau.fit$var.f)
  rval <- list(N0 = tau.fit$N0, N1 = tau.fit$N1, t = tau.fit$t[length(tau.fit$t)])

  tmp <- matrix(c(tau, se.r, tau / se.r,
                  stats::pchisq((tau / se.r) ^ 2, 1, lower.tail = FALSE)),
                nrow = 1)
  colnames(tmp) <- c("tau", "se(R)", "z(R)", "Pr(>|z|) (R)")
  row.names(tmp) <- ""
  rval$tau.fit.r <- tmp

  tmp <- matrix(c(tau, se.f, tau / se.f,
                  stats::pchisq((tau / se.f) ^ 2, 1, lower.tail = FALSE)),
                nrow = 1)
  colnames(tmp) <- c("tau", "se(F)", "z(F)", "Pr(>|z|) (F)")
  row.names(tmp) <- ""
  rval$tau.fit.f <- tmp

  if(conf.int) {
    z <- stats::qnorm((1 + conf.int) / 2)
    tmp <- matrix(c(tau, tau - z * se.r, tau + z * se.r, tau - z * se.f, tau + z * se.r),
                  nrow = 1)
    colnames(tmp) <- c("tau",
                       paste("lower .", round(100 * conf.int, 2), "(R)", sep = ""),
                       paste("upper .", round(100 * conf.int, 2), "(R)", sep = ""),
                       paste("lower .", round(100 * conf.int, 2), "(F)", sep = ""),
                       paste("upper .", round(100 * conf.int, 2), "(F)", sep = ""))
    row.names(tmp) <- " "
    rval$conf.int <- tmp
  }

  class(rval) <- "summaryTauFit"

  return(rval)
}
