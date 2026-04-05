library(mlr3)
library(mlr3spatiotempcv)
library(mlr3learners)
library(mlr3tuning)
library(SpatialML)
library(mlr3learners.spatialML)
library(ggplot2)
library(data.table)
library(future)

# Deux jeux de données (spatiaux) pour les tâches de régression
task_list <- list()

task_data <- mlr3::tsk("california_housing")$data()
task_data <- task_data[complete.cases(task_data), ]
set.seed(1) 
task_data <- task_data[sample(.N, 200), ]
task_data$ocean_proximity <- NULL

task_california <- as_task_regr_st(task_data, target = "median_house_value", coordinate_names = c("longitude", "latitude"))

data(Income, package = "SpatialML")
income_df <- as.data.frame(Income)
task_income = as_task_regr_st(income_df, target = "Income01", coordinate_names = c("X", "Y"), id = "Income")

task_list[["california_housing"]] <- task_california
task_list[["Income"]] <- task_income

# Learners

new_learner <- lrn("regr.grf", bw = 20, ntree = 50, id = "GRF")
featureless <- lrn("regr.featureless", id = "featureless")
cv_glmnet <- lrn("regr.cv_glmnet", id = "cv_glmnet")

knn_learner <- lrn("regr.kknn", id = "knn")
knn_learner$param_set$values$k <- paradox::to_tune(1,30)

kfoldcv <- mlr3::rsmp("cv")
kfoldcv$param_set$values$folds <- 3
knn_tuned <- mlr3tuning::auto_tuner(
  learner = knn_learner,
  tuner = mlr3tuning::tnr("grid_search"),
  resampling = kfoldcv,
  measure = mlr3::msr("regr.rmse")
)

learners <- list(
  new_learner,
  featureless,
  knn_tuned,
  cv_glmnet
)

# Benchmark

cv <- mlr3::rsmp("cv", folds = 5)
ma_grille <- mlr3::benchmark_grid(task_list, learners, cv)

unlink("dossier_registry", recursive=TRUE)
reg = batchtools::makeExperimentRegistry("dossier_registry")
mlr3batchmark::batchmark(ma_grille, store_models=FALSE, reg=reg)
job.table <- batchtools::getJobTable(reg=reg)
chunks <- data.frame(job.table, chunk=1)
batchtools::submitJobs(chunks, resources=list(
  walltime = 5*60*60, #seconds
  memory = 8000, #megabytes per cpu
  ncpus=1,
  ntasks=1,
  chunks.as.arrayjobs=TRUE), reg=reg)

jobs.after <- batchtools::getJobTable(reg=reg)
table(jobs.after$error) 
ids <- jobs.after[is.na(error), job.id]
bench_result <- mlr3batchmark::reduceResultsBatchmark(ids, reg = reg)
saveRDS(bench_result, "bench_result.rds")
score_dt <- bench_result$score(list(mlr3::msr("regr.rmse"), mlr3::msr("regr.rsq")))
data.table::fwrite(score_dt, "bench_scores.csv")

results_dt <- results_dt[, .(
  dataset = task_id,
  algorithm = learner_id,
  fold = iteration,
  rmse = regr.rmse
)]
