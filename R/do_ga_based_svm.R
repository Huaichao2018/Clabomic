#' Optimization of svm high-dimensional parameters based on genetic algorithm
#'
#' @param dat data frame with several numeric features and one Categorical variables at last column
#' @param positive_col the name of positive Categorical variable at last column
#' @param maxiter max generation
#'
#' @return fig and value
#' @export
#' @import pROC
#' @import GA
#' @import e1071
#' @import ggplot2
#' @import ggsci
#' @import parallel
#' @import doParallel
#' @examples
#' colnames(iris)[ncol(iris)] <- "group"
#' iris$group <- ifelse(iris$group == "setosa", "pos", "nag")
#' res <- do_ga_based_svm(iris, positive_col = "pos")
do_ga_based_svm <- function(dat, positive_col = "malignant",maxiter=100) {
  set.seed(1234)
  dat$group <- ifelse(dat$group == positive_col, 1, 0)
  K <- 5
  fold_inds <- sample(1:K, nrow(dat), replace = TRUE)

  ## split boston data into training & testing partitions
  cv_data <- lapply(
    1:K,
    function(index) {
      list(
        train_data = dat[fold_inds != index, , drop = FALSE],
        test_data = dat[fold_inds == index, , drop = FALSE]
      )
    }
  )
  # cv_data[[1]]
  # Define fitness function for GA iteration
  # Calculate root-mean-square deviation RMSD of the model over the test data.
  # RMSD quantifies difference between model predicted values and observed values. The formula is defined below:
  # Based on the values of parameters Gamma and C, the function to calculate RMSD is defined below:

  rmsd <- function(train_data, test_data, c, gamma) {
    ## train SVM model

    model <- svm(
      group ~ .,
      data = train_data,
      cost = c,
      gamma = gamma,
      type = "eps-regression",
      kernel = "radial"
    )

    ## test and calculate RMSD
    rmsd <- mean(
      (predict(model, newdata = test_data) - test_data$group)^2
    )

    ## return calculated RMSD
    return(rmsd)
  }

  # Based on the obtained RMSD, a fitness function for GA iteration process is further defined as below. Since R package GA can only maximize the fitness values of individuals, the negative values of RMSD is chosen here. Maximized negative RMSD corresponds to minimized positive RMSD.
  fitness_func <- function(x, cv_data) {
    ## fetch SVM parameters
    gamma_val <- x[1]
    c_val <- x[2]

    ## use cross validation to estimate RMSD for each partition of data set
    rmsd_vals <- sapply(
      cv_data,
      function(input_data) {
        with(
          input_data,
          rmsd(train_data, test_data, c_val, gamma_val)
        )
      }
    )

    ## return negative RMSD
    return(-mean(rmsd_vals))
  }


  ## Execute GA to achieve optimal SVM-RBF model parameter
  ## set value range for the parameters: Gamma & C
  para_value_min <- c(gamma = 1e-3, c = 1e-4)
  para_value_max <- c(gamma = 2, c = 10)

  ## run genetic algorithm
  results <- ga(
    type = "real-valued",
    fitness = fitness_func,
    cv_data,
    names = names(para_value_min),
    lower = para_value_min,
    upper = para_value_max, parallel = F,
    popSize = 50, # nBits =30,
    maxiter = maxiter
  )

  summary(results)

  out <- plot(results, col = c("#e41a1c", "#66c2a5", "#999999"))
  library(reshape2)
  df <- melt(out[, c(1:3, 5)], id.var = "iter")
  library(ggplot2)
  library(ggsci)

  last_fig <- ggplot(out) +
    geom_ribbon(aes(
      x = iter, ymin = median, ymax = max,
      colour = "median", fill = "median"
    )) +
    geom_line(aes(x = iter, y = max, colour = "max")) +
    geom_point(aes(x = iter, y = max, colour = "max")) +
    geom_line(aes(x = iter, y = mean, colour = "mean"), lty = 2) +
    geom_point(aes(x = iter, y = mean, colour = "mean"), pch = 1) +
    xlab("Generation") +
    ylab("Fitness values") +
    scale_colour_manual(
      breaks = c("max", "mean", "median"),
      values = c("green3", "dodgerblue3", adjustcolor("green3", alpha.f = 0.1))
    ) +
    scale_fill_manual(
      breaks = "median",
      values = adjustcolor("green3", alpha.f = 0.1)
    ) +
    guides(
      fill = "none",
      colour = guide_legend(
        override.aes =
          list(
            fill = c(NA, NA, adjustcolor("green3", alpha.f = 0.1)),
            pch = c(19, 1, NA)
          )
      )
    ) +
    theme_bw() +
    theme(
      legend.title = element_blank(),
      legend.pos = "top",
      legend.background = element_blank()
    ) +
    scale_color_simpsons()
  results <- summary(results)
  res <- list(last_fig, results)
  return(res)
}
