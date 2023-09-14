#' Estimate the Tau Process with/without cure fraction
#'
#' @param data a data.frame consisting of `arm`, `surv.time`, `event`.
#' @param t a sequence of specified times. If the user do not specify the sequence, the default is an equally-spaced sequence from 0 to the last identified time.
#' @param cure a boolean variable indicating whether to consider the cure fractions.
#'
#' @return an object of class "tau_process" with components
#' \tabular{ll}{
#' \code{t} \tab the specified sequence of time points \cr
#' \tab \cr
#' \code{vals_tau_proc} \tab the estimated value of tau measure at given time \cr
#' \tab \cr
#' \code{cure} \tab a boolean variable indicating whether to consider the cure fraction \cr
#' \tab \cr
#' \code{cure_rates} \tab the estimated cure rates for Group 0 and Group 1, respectively \cr
#' }
#'
#' @details The estimation method proposed by Yi-Cheng Tai, Weijing Wang and Martin T. Wells to estimate tau process with or without cure fraction.
#' @export
#'
#' @examples tau_proc(data = pbc)
tau_proc <- function(data, t = NULL, cure = FALSE) {

  ########
  time <- data$surv.time
  status <- data$event
  arm <- data$arm
  ########

  #### sample size ####
  n <- length(time)
  N0 <- sum(arm == 0)
  N1 <- sum(arm == 1)
  #####################

  if(is.na(N0)) print(sum(is.na(data$arm == 0)))
  if(is.na(N1)) print(sum(is.na(data$arm == 1)))
  if(!(N0 > 0 & N1 > 0)) return(NaN)

  #### two-sample data ####
  time_0 <- time[arm == 0]
  status_0 <- status[arm == 0]
  time_1 <- time[arm == 1]
  status_1 <- status[arm == 1]
  #########################

  if(length(t) == 0) {
    t <- seq(0, min(c(max(time_0), max(time_1))), length.out = 20)
  }

  #### survival functions of censoring variable ####
  G0_fit <- survival::survfit(survival::Surv(time_0, 1 - status_0) ~ 1)
  G1_fit <- survival::survfit(survival::Surv(time_1, 1 - status_1) ~ 1)
  G0_fun <- stats::stepfun(G0_fit$time, c(1, G0_fit$surv))
  G1_fun <- stats::stepfun(G1_fit$time, c(1, G1_fit$surv))
  ##################################################

  #### survival functions for susceptibles & cure rates ####
  S0a_fit <- survfit_susc(time_0, status_0)
  S1a_fit <- survfit_susc(time_1, status_1)
  S0a_fun <- stats::stepfun(S0a_fit$times, c(1, S0a_fit$surv))
  S1a_fun <- stats::stepfun(S1a_fit$times, c(1, S1a_fit$surv))
  cure_rate_0 <- S0a_fit$cure_rate
  cure_rate_1 <- S1a_fit$cure_rate
  ##########################################################

  #### all combinations ####
  time_mat_0 <- matrix(time_0, nrow = N0, ncol = N1)
  time_mat_1 <- matrix(time_1, nrow = N0, ncol = N1, byrow = TRUE)
  status_mat_0 <- matrix(as.logical(status_0), nrow = N0, ncol = N1)
  status_mat_1 <- matrix(as.logical(status_1), nrow = N0, ncol = N1, byrow = TRUE)
  ##########################

  #### weights ####
  S0a_vals <- S0a_fun(time_mat_0)
  susc_probs_0 <- S0a_vals * (1 - cure_rate_0) / (S0a_vals * (1 - cure_rate_0) + cure_rate_0)
  w_0 <- ifelse(status_mat_0 == 1, 1, susc_probs_0)

  S1a_vals <- S1a_fun(time_mat_1)
  susc_probs_1 <- S1a_vals * (1 - cure_rate_1) / (S1a_vals * (1 - cure_rate_1) + cure_rate_1)
  w_1 <- ifelse(status_mat_1 == 1, 1, susc_probs_1)

  w_mat <- w_0 * w_1
  #################

  #### minimum time of all pairs ####
  min_ind_0 <- time_mat_0 < time_mat_1
  min_ind_1 <- time_mat_1 < time_mat_0
  min_time_mat <- ifelse(min_ind_0, time_mat_0, time_mat_1)
  ###################################

  #### orderable indicator ####
  orderable_ind <- ifelse(min_ind_0, status_mat_0, 0)
  orderable_ind <- ifelse(min_ind_1, status_mat_1, orderable_ind)
  #############################

  #### restricted region indicator ####
  restricted_ind <- lapply(t, ">=", min_time_mat)
  #####################################

  #### G0 and G1 at the minimum time ####
  G0_vals <- apply(X = min_time_mat, MARGIN = 2, FUN = G0_fun)
  G1_vals <- apply(X = min_time_mat, MARGIN = 2, FUN = G1_fun)
  #######################################

  #### concordance and discordance ####
  conc <- ifelse(min_ind_0, 1, 0)
  conc <- ifelse(min_ind_1, -1, conc)
  #####################################

  #### results ####
  if(cure) {
    conc_ipcw <- ifelse(orderable_ind, w_mat * conc / G0_vals / G1_vals, 0)
    conc_ipcw <- lapply(restricted_ind, "*", conc_ipcw)
    vals_tau_proc <- sapply(conc_ipcw, sum)
    vals_tau_proc <- sapply(vals_tau_proc, "/", N0 * N1)
    vals_tau_proc <- sapply(vals_tau_proc, "/", (1 - cure_rate_0) * (1 - cure_rate_1))

    rvals <- list(t = t,
                  vals_tau_proc = vals_tau_proc,
                  cure = cure,
                  cure_rates = c(cure_rate_0, cure_rate_1))
  } else {
    conc_ipcw <- ifelse(orderable_ind, conc / G0_vals / G1_vals, 0)
    conc_ipcw <- lapply(restricted_ind, "*", conc_ipcw)
    vals_tau_proc <- sapply(conc_ipcw, sum)
    vals_tau_proc <- sapply(vals_tau_proc, "/", N0 * N1)

    rvals <- list(t = t,
                  vals_tau_proc = vals_tau_proc,
                  cure = cure)
  }
  #################

  class(rvals) <- "tau_process"
  rvals
}
