var.fixed <- function(data, obj) {
  n <- nrow(data)
  p0 <- mean(data$arm == 0)
  p1 <- 1 - p0

  var2 <- var2.random(data = data, obj = obj)
  var3 <- var3.random(data = data, obj = obj)
  var3 <- var3 + 4 * obj$tau ^ 2 - obj$tau ^ 2 / (p0 * p1)

  return((var3 - var2) / n)
}
