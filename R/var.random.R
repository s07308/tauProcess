var.random <- function(data, obj) {
  n <- nrow(data)
  var1 <- var1.random(data = data, obj = obj)
  var2 <- var2.random(data = data, obj = obj)
  var3 <- var3.random(data = data, obj = obj)

  return((var3 - var2 - var1) / n)
}

var1.random <- function(data, obj) {
  p1 <- mean(data$arm == 1)
  p0 <- 1 - p1
  var1 <- obj$tau ^ 2 * (p1 - p0) ^ 2 / (p0 * p1)

  return(var1)
}

var2.random <- function(data, obj) {
  n <- nrow(data)
  kappa.val <- sapply(X = data$surv.time,
                      FUN = function(u) {
                        trunc.indicator <- (obj$min.surv.time.mat >= u)
                        kappa.val <- ifelse(trunc.indicator,
                                            obj$conc.ipcw,
                                            0)
                        return(sum(kappa.val) / choose(n, 2))
                      })

  R0 <- apply(sapply(X = data$surv.time, FUN = "<=", data$surv.time[data$arm == 0]), 2, sum)
  R1 <- apply(sapply(X = data$surv.time, FUN = "<=", data$surv.time[data$arm == 1]), 2, sum)
  var2.0 <- n * sum(ifelse((1 - data$event) * (1 - data$arm), (kappa.val / R0) ^ 2, 0))
  var2.1 <- n * sum(ifelse((1 - data$event) * data$arm, (kappa.val / R1) ^ 2, 0))
  p1 <- mean(data$arm == 1)
  p0 <- 1 - p1
  var2 <- (var2.0 + var2.1) / (4 * p0 ^ 2 * p1 ^ 2)

  return(var2)
}

var3.random <- function(data, obj) {
  n <- nrow(data)
  N0 <- sum(data$arm == 0)
  N1 <- sum(data$arm == 1)

  cross.prod.0 <- sum(sapply(1:N0, FUN = function(i) {
    sum(sapply(obj$conc.ipcw[i, ], "*", obj$conc.ipcw[i, ]))
  }))

  cross.prod.1 <- sum(sapply(1:N1, FUN = function(j) {
    sum(sapply(obj$conc.ipcw[, j], "*", obj$conc.ipcw[, j]))
  }))

  p1 <- mean(data$arm == 1)
  p0 <- 1 - p1
  theta1.square <- (cross.prod.0 + cross.prod.1) / n ^ 3 - (2 * p0 * p1 * obj$tau) ^ 2
  var3 <- 4 * theta1.square / (2 * p0 * p1) ^ 2

  return(var3)
}
