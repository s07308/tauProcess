tau_est <- function(arm, surv.time, event, t) {
  fit <- tau_fit(data.frame(arm, surv.time, event), t)
  return(fit$tau)
}
