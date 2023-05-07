usethis::create_package('Clabomic')
renv::init()
renv::snapshot()
renv::update()
usethis::use_package(package = "renv", type = "Suggests")
usethis::use_package(package = "ggplot2", type =  "Import")
usethis::use_package(package = "caret", type =  "Import")
usethis::use_package(package = "dplyr", type =  "Import")
usethis::use_package(package = "GA", type =  "Import")
usethis::use_package(package = "e1071", type =  "Import")
usethis::use_package(package = "FSelector", type =  "Import")
usethis::use_package(package = "rpart", type =  "Import")
usethis::use_package(package = 'parallel', type =  "Import")
usethis::use_package(package = 'doParallel', type =  "Import")
usethis::use_package(package = 'ggsci', type =  "Import")
usethis::use_package(package = 'pROC', type =  "Import")
usethis::use_package(package = 'tidyr', type =  "Import")

#1.写完一个函数就执行
file.create("R/do_batch_Wilcoxon.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?do_batch_Wilcoxon
colnames(iris)[ncol(iris)]='group'
iris_batch_wilcoxon_res=do_batch_Wilcoxon(iris)
#2.
file.create("R/do_batch_roc.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?do_batch_roc
colnames(iris)[ncol(iris)]='group'
iris_batch_wilcoxon_res=do_batch_roc(iris)

#3.
file.create("R/do_batch_feature_sel.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?do_batch_feature_sel
colnames(iris)[ncol(iris)]='group'
iris_batch_wilcoxon_res=do_batch_feature_sel(iris)

#3.
file.create("R/do_batch_feature_sel.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?do_batch_feature_sel
colnames(iris)[ncol(iris)]='group'
iris_batch_wilcoxon_res=do_batch_feature_sel(iris)
#4.
file.create("R/cut_off_selecting.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?cut_off_selecting
colnames(iris)[ncol(iris)]='group'
iris_batch_wilcoxon_res=do_batch_feature_sel(iris)
#5.
file.create("R/do_ga_based_svm.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?do_ga_based_svm
#6.
file.create("R/svm_importance.R")
styler::style_pkg()
devtools::load_all()
devtools::document()
?svm_importance

#7.
file.create("R/get_best_svm.R")
styler::style_pkg()
devtools::load_all()
devtools::document()


#'8
file.create("R/do_muti_roc.R")

#9.
file.create("R/do_muti_dca.R")

#10.check
devtools::check()

#11.rmd
usethis::use_readme_rmd()
usethis::use_pkgdown()
pkgdown::build_site()
usethis::use_tidy_github_actions()

devtools::build_rmd(files = "./README.Rmd",path = "./")
#12.
renv::update()
renv::snapshot()
usethis::use_vignette("Clabomic_vignette")
devtools::build()

#13
install.packages("../Clabomic_0.0.0.9000.tar.gz",
                 repos=NULL, type="source")
#13.

