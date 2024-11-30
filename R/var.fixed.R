var.fixed <- function(time, status, arm, obj) {
  n <- length(time)
  p0 <- mean(arm == 0)
  p1 <- 1 - p0

  var2 <- var2.random(time, status, arm, obj)
  var3 <- var3.random(time, status, arm, obj)
  var3 <- var3 + 4 * obj$tau ^ 2 - obj$tau ^ 2 / (p0 * p1)

  return((var3 - var2) / n)
}
