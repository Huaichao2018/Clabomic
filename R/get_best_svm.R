#' To get bset svm model
#'
#' @param Train training data
#' @param res result from do_ga_based_svm.R
#'
#' @return best_model
#' @export
#'
#' @examples
#' library(Clabomic)
#' colnames(iris)[ncol(iris)] <- "group"
#' iris$group <- ifelse(iris$group == "setosa", "pos", "nag")
#' res <- do_ga_based_svm(iris, positive_col = "pos")
#' best_model <- get_best_svm(iris,res)
get_best_svm <- function(Train, res) {
  best_model <- svm(group ~ .,
    data = Train,
    gamma = signif(res[[2]]$solution[1], 3),
    cost =  signif(res[[2]]$solution[2], 3),
    type = "eps-regression",
    kernel = "radial"
  )
  return(best_model)
}

