#' svm_importance evaluate
#'
#' @param best_model best_model by cost and gamma by do_ga_based_svm
#'
#' @return svm_importance data frame
#' @export
#'
#' @examples
#' library(Clabomic)
#' colnames(iris)[ncol(iris)] <- "group"
#' iris$group <- ifelse(iris$group == "setosa", "pos", "nag")
#' res <- do_ga_based_svm(iris, positive_col = "pos")
#' best_model <- svm(group ~ ., data = Train, gamma = signif(res[[2]]$solution[1], 3), cost = signif(res[[2]]$solution[2], 3))
#' importance <- svm_importance(best_model)
svm_importance <- function(best_model) {
  w <- as.data.frame(t(best_model$coefs) %*% best_model$SV)
  w <- abs(w)
  w <- sort(w, decreasing = T) %>% .[, 1:3]
  w <- pivot_longer(w, colnames(w), names_to = "id", values_to = "weights")
  p <- ggplot(w, aes(x = reorder(id, weights), y = weights, fill = weights)) +
    geom_col() +
    scale_fill_gradientn(colours = c("#e5f5f9", "#99d8c9", "#2ca25f")) +
    coord_flip() +
    theme_classic() +
    labs(x = "features") +
    theme(text = element_text(size = 25))
  p
  return(w)
}
