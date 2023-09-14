survfit_susc <- function(time, status) {
  fit <- survival::survfit(survival::Surv(time, status) ~ 1)
  cure_rate <- min(fit$surv)

  times <- fit$time
  Sa_fit <- (fit$surv - cure_rate) / (1 - cure_rate)

  rval <- list(times = times[fit$n.event > 0],
               surv = Sa_fit[fit$n.event > 0],
               cure_rate = cure_rate)

  return(rval)
}
