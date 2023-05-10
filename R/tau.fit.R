#' Estimate the Tau Process
#' @description Estimate the tau process at specified time points.
#' The estimated variances at the last time point under complete randomization design and random allocation rule (urn model) are provided.
#' @param data a data.frame consisting of `arm`, `surv.time`, `event`.
#' @param t a sequence of specified times. If the user do not specify the sequence, the default is an equally-spaced sequence from 0 to the last identified time.
#'
#' @return an object of class "tauFit" with components
#' \tabular{ll}{
#' \code{N0} \tab number of individuals with arm=0 \cr
#' \tab \cr
#' \code{N1} \tab number of individuals with arm=1 \cr
#' \tab \cr
#' \code{t} \tab the specified truncation time \cr
#' \tab \cr
#' \code{tau} \tab the estimated value of tau measure \cr
#' \tab \cr
#' \code{var.r} \tab the estimated variance under random grouping design (complete randomization design)\cr
#' \tab \cr
#' \code{var.f} \tab the estimated variance under fixed grouping design (random allocation rule / urn model)\cr
#' }
#'
#' @details The estimation and inference procedure are proposed by Yi-Cheng Tai, Weijing Wang and Martin T. Wells.
#' The value of tau measure serves as a clinically meaningful measure of treatment effect.
#' It supplements the traditional hazard ratio (HR) under nonproportional hazard scenario.
#'
#' @export
#'
#' @examples tau.fit(data = pbc)
#'
tau.fit <- function(data, t = numeric()) {
  stopifnot(is.numeric(t))
  stopifnot(is.data.frame(data))

  n <- length(data$surv.time)
  N0 <- sum(data$arm == 0)
  N1 <- sum(data$arm == 1)
  surv.time.0 <- data$surv.time[data$arm == 0]
  event.0 <- data$event[data$arm == 0]
  surv.time.1 <- data$surv.time[data$arm == 1]
  event.1 <- data$event[data$arm == 1]

  t <- sort(unique(t))

  if(length(t) == 0) {
    t <- seq(0, min(c(max(surv.time.0), max(surv.time.1))), length.out = 20)
  }

  ## estiamte the survival functions of censoring variable
  G0.fit <- survival::survfit(survival::Surv(surv.time.0, 1 - event.0) ~ 1)
  G1.fit <- survival::survfit(survival::Surv(surv.time.1, 1 - event.1) ~ 1)
  G0.fit_func <- stats::stepfun(G0.fit$time, c(1, G0.fit$surv))
  G1.fit_func <- stats::stepfun(G1.fit$time, c(1, G1.fit$surv))

  ## all combinations
  surv.time.mat.0 <- matrix(surv.time.0, nrow = N0, ncol = N1)
  surv.time.mat.1 <- matrix(surv.time.1, nrow = N0, ncol = N1, byrow = TRUE)
  event.mat.0 <- matrix(as.logical(event.0), nrow = N0, ncol = N1)
  event.mat.1 <- matrix(as.logical(event.1), nrow = N0, ncol = N1, byrow = TRUE)

  ## minimum survival time of all pairs
  min.index.0 <- surv.time.mat.0 < surv.time.mat.1
  min.index.1 <- surv.time.mat.1 < surv.time.mat.0
  min.surv.time.mat <- ifelse(min.index.0, surv.time.mat.0, surv.time.mat.1)

  ## orderable indicator
  orderable.indicator <- ifelse(min.index.0, event.mat.0, 0)
  orderable.indicator <- ifelse(min.index.1, event.mat.1, orderable.indicator)

  ## restricted region indicator
  # restricted.indicator <- ifelse(min.surv.time.mat <= t, 1, 0)
  restricted.indicator <- lapply(t, ">=", min.surv.time.mat)

  ## G0.hat and G1.hat at the minimum survival time
  G0.val <- apply(X = min.surv.time.mat, MARGIN = 2, FUN = G0.fit_func)
  G1.val <- apply(X = min.surv.time.mat, MARGIN = 2, FUN = G1.fit_func)

  ## concordance and discordance
  conc <- ifelse(min.index.0, 1, 0)
  conc <- ifelse(min.index.1, -1, conc)
  conc.ipcw <- ifelse(orderable.indicator * restricted.indicator[[length(t)]],
                      conc / G0.val / G1.val,
                      0)
  tau.est.seq <- lapply(restricted.indicator, "*", orderable.indicator)
  tau.est.seq <- lapply(tau.est.seq, ifelse, conc / G0.val / G1.val, 0)
  tau.est.seq <- sapply(tau.est.seq, sum) / N0 / N1

  ## tau inference
  # tau.est <- sum(conc.ipcw) / N0 / N1
  obj.fit <- list(min.surv.time.mat = min.surv.time.mat,
                  restricted.indicator = restricted.indicator[[length(t)]],
                  orderable.indicator = orderable.indicator,
                  conc.ipcw = conc.ipcw,
                  tau = tau.est.seq[[length(t)]])
  var.r <- var.random(data, obj.fit)
  var.f <- var.fixed(data, obj.fit)

  rval <- list(N0 = N0,
               N1 = N1,
               t = t,
               tau = tau.est.seq,
               var.r = var.r,
               var.f = var.f)

  class(rval) <- "tauFit"

  return(rval)
}
