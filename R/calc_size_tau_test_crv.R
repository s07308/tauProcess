calc_size_tau_test_crv <- function(target_tau,
                                   G0,
                                   G1,
                                   p1,
                                   sig_level = 0.05,
                                   power = 0.90,
                                   alternative = c("less", "greater")) {
  p0 <- 1 - p1
  z_alpha <- qnorm(sig_level)
  z_beta <- qnorm(1 - power)

  switch(alternative,
         "greater" = (z_alpha + z_beta)^2 / (p1^2 * p0^2 * G1^2 * G0^2 * target_tau^2),
         "less" = "",
         "two.sided" = "",
         stop())
}
