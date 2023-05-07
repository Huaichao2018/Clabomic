#' The last column is used as grouping, and the other columns are subjected to feature project
#'
#' @param mat a data frame,the last column is 'group', and the content is binary classification text
#'
#' @import pROC
#' @import FSelector
#' @import caret
#' @import rpart
#' @import ggplot2
#' @return features weights with three tools
#' @export
#'
#' @examples
#' library(Clabomic)
#' colnames(iris)[ncol(iris)] <- "group"
#' res <- do_batch_feature_sel(iris)
do_batch_feature_sel <- function(mat) {
  mat$group <- factor(mat$group)
  weights <- random.forest.importance(group ~ ., mat, importance.type = 1)
  print(weights)
  subset1 <- cutoff.k(weights, 40)
  weights1 <- weights[subset1, ]
  weights2 <- information.gain(group ~ ., mat)
  subset2 <- cutoff.k(weights2, 40)
  varlist <- union(subset1, subset2)
  mat <- mat[, c(varlist, "group")]
  # evaludate the varlist
  # 10 fold cross validation
  evaluator <- function(varlist) {
    f <- as.simple.formula(varlist, "group")
    k <- 10
    set.seed(1234)
    ind <- sample(20, nrow(mat), replace = T)
    results <- sapply(1:k, function(i) {
      train <- mat[ind != i, ]
      test <- mat[ind == i, ]
      tree <- rpart(f, mat)
      error.rate <- sum(test$group != predict(tree, test, type = "class")) / nrow(test)
      return(1 - error.rate)
    })
    print(mean(results))
    return(mean(results))
  }
  attr_subset <- hill.climbing.search(names(mat)[-ncol(mat)], evaluator)
  lastvar <- list(
    hill.climbing.search = attr_subset,
    random.forest.importance = weights,
    information.gain = weights2
  )
  return(lastvar)
}
