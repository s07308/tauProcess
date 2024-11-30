var.random <- function(time, status, arm, obj) {
  n <- length(time)
  var1 <- var1.random(time, status, arm, obj)
  var2 <- var2.random(time, status, arm, obj)
  var3 <- var3.random(time, status, arm, obj)

  return((var3 - var2 - var1) / n)
}

var1.random <- function(time, status, arm, obj) {
  p1 <- mean(arm == 1)
  p0 <- 1 - p1
  var1 <- obj$tau ^ 2 * (p1 - p0) ^ 2 / (p0 * p1)

  return(var1)
}

var2.random <- function(time, status, arm, obj) {
  n <- length(time)
  kappa.val <- sapply(X = time,
                      FUN = function(u) {
                        trunc.indicator <- (obj$min.surv.time.mat >= u)
                        kappa.val <- ifelse(trunc.indicator,
                                            obj$conc.ipcw,
                                            0)
                        return(sum(kappa.val) / choose(n, 2))
                      })

  R0 <- apply(sapply(X = time, FUN = "<=", time[arm == 0]), 2, sum)
  R1 <- apply(sapply(X = time, FUN = "<=", time[arm == 1]), 2, sum)
  var2.0 <- n * sum(ifelse((1 - status) * (1 - arm), (kappa.val / R0) ^ 2, 0))
  var2.1 <- n * sum(ifelse((1 - status) * arm, (kappa.val / R1) ^ 2, 0))
  p1 <- mean(arm == 1)
  p0 <- 1 - p1
  var2 <- (var2.0 + var2.1) / (4 * p0 ^ 2 * p1 ^ 2)

  return(var2)
}

var3.random <- function(time, status, arm, obj) {
  n <- length(time)
  N0 <- sum(arm == 0)
  N1 <- sum(arm == 1)

  cross.prod.0 <- sum(sapply(1:N0, FUN = function(i) {
    sum(sapply(obj$conc.ipcw[i, ], "*", obj$conc.ipcw[i, ]))
  }))

  cross.prod.1 <- sum(sapply(1:N1, FUN = function(j) {
    sum(sapply(obj$conc.ipcw[, j], "*", obj$conc.ipcw[, j]))
  }))

  p1 <- mean(arm == 1)
  p0 <- 1 - p1
  theta1.square <- (cross.prod.0 + cross.prod.1) / n ^ 3 - (2 * p0 * p1 * obj$tau) ^ 2
  var3 <- 4 * theta1.square / (2 * p0 * p1) ^ 2

  return(var3)
}
