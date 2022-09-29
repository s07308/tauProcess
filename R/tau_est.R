#' Estimate of local Kendall's tau with right-censored data
#'
#' @param arm a non-empty numeric vector of group indicators, coded as 0 or 1.
#' @param surv.time a non-empty numeric vector of survival times (possibly censored).
#' @param event the censoring indicator coded as 0 if censored; as 1 if failed
#' @param t the specified time point
#'
#' @return the estimated value of local Kendall's tau at specified time.
#' @export
#'
#' @examples
tau_est <- function(arm, surv.time, event, t) {
  fit <- tau_fit(data.frame(arm, surv.time, event), t)
  return(fit$tau)
}
