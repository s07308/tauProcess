#' Calculate the conservative required sample size for one-sided test
#'
#' @param target_tau The value of tau measure under alternative
#' @param G0 Censoring rate for control arm
#' @param G1 Censoring rate for treatment arm
#' @param p1 Assignment probability to treatment arm
#' @param sig_level Level of significance
#' @param power Expected power to attain
#'
#' @returns A single number indicating the required sample size
#' @export
#'
#' @examples
#' calc_size_tau_test_crv(0.5, 0.1, 0.1, 0.5)
calc_size_tau_test_crv <- function(target_tau,
                                   G0,
                                   G1,
                                   p1,
                                   sig_level = 0.05,
                                   power = 0.90) {
  p0 <- 1 - p1
  z_alpha <- stats::qnorm(sig_level)
  z_beta <- stats::qnorm(1 - power)

  (z_alpha + z_beta)^2 / (p1^2 * p0^2 * G1^2 * G0^2 * target_tau^2)
}
