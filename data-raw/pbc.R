## code to prepare `pbc` dataset goes here
data(pbc, package = "survival")
pbc <- na.omit(pbc)
pbc <- pbc[, c("time", "status", "trt")]
pbc <- pbc[pbc$status != 1, ]
pbc$status <- ifelse(pbc$status == 2, 1, pbc$status)
pbc$trt <- ifelse(pbc$trt == 2, 0, pbc$trt)
colnames(pbc) <- c("surv.time", "event", "arm")

usethis::use_data(pbc, overwrite = TRUE)
