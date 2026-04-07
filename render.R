pkgs <- c("pkgdown", "mlr3", "mlr3learners", "mlr3spatiotempcv", "SpatialML", "kknn", "glmnet", "rmarkdown", "knitr")
ins.mat <- installed.packages()
missing.pkgs <- setdiff(pkgs, rownames(ins.mat))
install.packages(missing.pkgs)

pkgdown::clean_site(force = TRUE)

out <- capture.output(te <- try(pkgdown::build_site()))
print(te)
cat(out, sep="\n")
cat(out, sep="\n", file="index_file.log")

if(inherits(te, "try-error")) stop("Error during pkgdown site generation")