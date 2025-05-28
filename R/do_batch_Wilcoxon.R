#' The last column is used as grouping, and the other columns are subjected to Wilcoxon test
#'
#' @param mat a data frame,the last column is 'group', and the content is binary classification text
#' @param p_value the cut off value of p value
#' @return Wilcoxon test results
#' @import dplyr
#' @export
#'
#' @examples
#' library(Clabomic)
#' colnames(iris)[ncol(iris)] <- "group"
#' iris_batch_wilcoxon_res <- do_batch_Wilcoxon(iris)
do_batch_Wilcoxon <- function(mat,p_value=0.05) {
  # wilcon first step to select factor
  test.fun <- function(dat, col) {
    # dat=mat;col=1
    index <- unique(dat$group)
    sigs <- wilcox.test(
      dat[dat$group == index[1], col],
      dat[dat$group == index[2], col]
    )

    tests <- data.frame(
      W = sigs$statistic,
      p = sigs$p.value,
      mean_x = mean(dat[dat$group == index[1], col]),
      mean_y = mean(dat[dat$group == index[2], col]),
      median_x = median(dat[dat$group == index[1], col]),
      median_y = median(dat[dat$group == index[2], col])
    )

    return(tests)
  }

  # mat=do_process_res[[1]]
  tests <- do.call(rbind, lapply(colnames(mat)[-ncol(mat)], function(x) test.fun(mat, x)))
  rownames(tests) <- colnames(mat)[-ncol(mat)]

  test_sig <- tests[tests$p <p_value, ]
  str(test_sig)
  test_sig$p.adjust <- p.adjust(test_sig$p, method = "bonferroni")
  test_sig <- test_sig[order(test_sig$p), ]

  ## calculate the sd and logFC
  # mat=do_process_res[[1]]
  sd_file <- mat %>%
    group_by(group) %>%
    summarise_all(sd) %>%
    t(.)
  colnames(sd_file) <- sd_file[1, ]
  sd_file <- as.data.frame(sd_file[-1, ])
  sd_file$id <- rownames(sd_file)
  colnames(sd_file)[1:2] <- paste("sd", colnames(sd_file)[1:2], sep = "_")
  mean_file <- mat %>%
    group_by(group) %>%
    summarise_all(mean) %>%
    select(-group) %>%
    log2(.)
  logFC <- mean_file[2, ] - mean_file[1, ]
  logFC <- as.data.frame(t(logFC))
  logFC$id <- rownames(logFC)
  colnames(logFC)[1] <- "logFC"

  rownames(test_sig)
  test_sig$id <- rownames(test_sig)
  last_test_sig <- merge(test_sig, sd_file, by = "id")
  last_test_sig <- merge(last_test_sig, logFC, by = "id")
  last_test_sig <- last_test_sig[order(last_test_sig$p), ]
  last_test_sig$change <- last_test_sig$change <- as.factor(
    ifelse(last_test_sig$p < 0.05, ifelse(last_test_sig$logFC > 0.5, "Up",
      ifelse(last_test_sig$logFC < -0.5, "Down", "Stable")
    ))
  )

  return(last_test_sig)
}
