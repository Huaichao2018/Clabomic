#' Constuct several roc lines in one fig
#'
#' @param roc.list
#'
#' @return
#' @export
#' @import pROC
#' @examples
#' library(Clabomic)
#' library(pROC)
#' colnames(iris)[ncol(iris)] <- "group"
#' roc.list <- list(Train = roc(iris$group, iris$Sepal.Length), Test = roc(iris$group, iris$Sepal.Width))
#' do_muti_roc(roc.list)
do_muti_roc <- function(roc.list) {
  fig <- ggroc(roc.list,
    alpha = 0.9, size = 1.5, linetype = 1
  ) +
    theme_bw() + theme(legend.position = "none") + theme(text = element_text(size = 25))
  return(fig)
}
