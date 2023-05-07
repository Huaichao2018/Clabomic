#' selecting cutofff by proc output
#'
#' @param roc proc output
#' @param cutoff one value for divide data into two group
#' @param sen let the sensitivities is at least one value
#' @param spe let the specificities is at least one value
#' @import pROC
#' @return cutoff value
#' @export
#'
#' @examples
#' library(Clabomic)
#' library(pROC)
#' colnames(iris)[ncol(iris)] <- "group"
#' roc <- roc(iris$group, iris$Sepal.Length)
#' cutoff <- cut_off_selecting(roc)
cut_off_selecting <- function(roc, cutoff_type = "youden", sen = 0.9, spe = 0.9) {
  if (cutoff_type == "youden") {
    cutoff <- roc$thresholds[(roc$sensitivities + roc$specificities) == max(roc$sensitivities + roc$specificities)]
    cutoff <- round(cutoff, 4)
  }
  if (cutoff_type == "sensitivities") {
    cutoff <- max(roc$thresholds[roc$sensitivities >= sen])
    cutoff <- round(cutoff, 4)
  }
  if (cutoff_type == "specificities") {
    cutoff <- min(roc$thresholds[roc$specificities >= spe])
    cutoff <- round(cutoff, 4)
  }
  return(cutoff)
}
