#' The last column is used as grouping, and the other columns are subjected to roc test
#'
#' @param dat a data frame,the last column is 'group', and the content is binary classification text
#' @import pROC
#' @return roc test results
#' @export
#'
#' @examples
#' library(Clabomic)
#' colnames(iris)[ncol(iris)] <- "group"
#' res <- do_batch_roc(iris)
do_batch_roc <- function(dat) {
  index <- colnames(dat)
  res <- c()
  for (i in 1:(ncol(dat) - 1)) {
    # i=1
    tem_dat <- dat[, c(i, ncol(dat))]
    colnames(tem_dat)[1] <- "feature"
    tem_dat$feature <- as.numeric(tem_dat$feature)
    tem_roc <- roc(group ~ feature, data = tem_dat, ci = T)
    res[index[i]] <- round(tem_roc$auc, 2)
  }
  return(as.data.frame(res))
}
