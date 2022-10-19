#' Two-Sample inference based on local Kendall's tau
#' @description calculate the necessary elements to do inference based on tau
#' @param data a data.frame consisting of `arm`, `surv.time`, `event`.
#' @param t the specified truncation time.
#'
#' @return a list with components
#' \tabular{ll}{
#' \code{N0} \tab number of individuals with arm=0 \cr
#' \tab \cr
#' \code{N1} \tab number of individuals with arm=1 \cr
#' \tab \cr
#' \code{t} \tab the specified truncation time \cr
#' \tab \cr
#' \code{var.r} \tab estimated variance under random grouping design \cr
#' \tab \cr
#' \code{var.f} \tab estimated variance under fixed grouping design \cr
#' \tab \cr
#' \code{obj} \tab a list of components to \cr
#' \tab \cr
#' \code{class}
#' }
#'
#' @details The estimating formula for tau and variance are proposed by Yi-Cheng Tai, Weijing Wang and Martin T. Wells.
#'
#' @export
#'
#'
tau_fit <- function(data, t) {
  n <- length(data$surv.time)
  N0 <- sum(data$arm == 0)
  N1 <- sum(data$arm == 1)
  surv.time.0 <- data$surv.time[data$arm == 0]
  event.0 <- data$event[data$arm == 0]
  surv.time.1 <- data$surv.time[data$arm == 1]
  event.1 <- data$event[data$arm == 1]

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
  restricted.indicator <- ifelse(min.surv.time.mat <= t, 1, 0)

  ## G0.hat and G1.hat at the minimum survival time
  G0.val <- apply(X = min.surv.time.mat, MARGIN = 2, FUN = G0.fit_func)
  G1.val <- apply(X = min.surv.time.mat, MARGIN = 2, FUN = G1.fit_func)

  ## concordance and discordance
  conc <- ifelse(min.index.0, 1, 0)
  conc <- ifelse(min.index.1, -1, conc)
  conc.ipcw <- ifelse(orderable.indicator * restricted.indicator,
                      conc / G0.val / G1.val,
                      0)

  ## tau inference
  tau.est <- sum(conc.ipcw) / N0 / N1
  obj.fit <- list(min.surv.time.mat = min.surv.time.mat,
                  restricted.indicator = restricted.indicator,
                  orderable.indicator = orderable.indicator,
                  conc.ipcw = conc.ipcw,
                  tau = tau.est)
  var.r <- var_random(data, obj.fit)
  var.f <- var_fixed(data, obj.fit)

  rval <- list(N0 = N0,
               N1 = N1,
               t = t,
               var.r = var.r,
               var.f = var.f,
               obj = obj.fit)

  class(rval) <- "tauFit"

  return(rval)
}
