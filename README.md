
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tauProcess

<!-- badges: start -->
<!-- badges: end -->

In clinical trials, the nonproportional hazard (NPH) scenarios are
commonly encountered. Under NPH, the classical hazard ratio is no longer
a meaningful treatment effect measure. Furthermore, the commonly used
logrank test may lose its power. Several treatment effect measures and
testing procedures are proposed to overcome these problems, including
weighted logrank, restricted mean survival time (RMST) and maxcombo
tests. The tau measure/process proposed is intuitive and clinically
meaningful to accommodate the requirements from addendum to ICH E9
highlighting the interpretability of estimand. The inference procedure
and plot based on tau measure and process are also provided.

## Installation

You can install the development version of tauProcess from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("s07308/tauProcess")
```

## Usage & Example

This is a basic example which shows you how to estimate the tau process
and make the corresponding statistical inference:

``` r
library(tauProcess)
fit <- tau.fit(data = pbc)
```

You may use `summary()` to check the inference results at the largest
time specified:

``` r
summary(fit)
#>  N0= 131  N1= 127  The truncation time is specified as 4523 
#> 
#> Random grouping design:
#>      tau   se(R)  z(R) Pr(>|z|) (R)
#>  -0.0503  0.0906 -0.55         0.58
#> 
#> Fixed grouping design:
#>      tau   se(F)  z(F) Pr(>|z|) (F)
#>  -0.0503  0.0906 -0.55         0.58
#> 
#>       tau lower .95(R) upper .95(R) lower .95(F) upper .95(F)
#>   -0.0503       -0.228        0.127       -0.228        0.127
```

Furthermore, `plot()` will provide you the estimated tau process to
investigate the evolution of treatment effect:

``` r
plot(fit, type = "b")
```

<img src="man/figures/README-plot-tau-process-no-cure-1.png" width="100%" />

For the case with possibly existing cure fraction, we may estimate the
tau process for the susceptible subgroups:

``` r
fit_cure <- tau_proc(pbc, cure = TRUE)
```

The bootstrap method is recommended to do statistical inference about
the tau process for susceptible subgroups. As the case with no cure
fraction, we may plot the estimated tau process as well:

``` r
plot(fit_cure, type = "b")
```

<img src="man/figures/README-plot-tau-process-with-cure-1.png" width="100%" />
