#' Mayo Clinic Primary Biliary Cholangitis Data
#'
#' This dataset is obtained from 'pbc' in package 'survival' by excluding the non-randomized individuals.
#' For background and details of the original dataset, please refer to the document page of 'survival'.
#'
#' @format ## `pbc`
#' A data frame with 258 rows and 3 columns:
#' \describe{
#'   \item{surv.time}{the survival of each subject in the trial (days)}
#'   \item{event}{censoring indicator (1: dead; 0: censored)}
#'   \item{arm}{treatment arm (1: D-penicillamine; 0: placebo)}
#' }
#' @source <https://cran.r-project.org/package=survival>
"pbc"
