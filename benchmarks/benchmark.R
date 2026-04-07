library(mlr3)
library(mlr3spatiotempcv)
library(mlr3learners)
library(mlr3tuning)
library(SpatialML)
library(mlr3learners.spatialML)
library(batchtools)
library(mlr3batchmark)
library(data.table)

# Data config
task_list <- list()
sample_size_california <- 200
seed_value <- 1

# Data Prep : California Housing
california_dt <- mlr3::tsk("california_housing")$data()
california_dt <- california_dt[complete.cases(california_dt), ]

# Sampling data
set.seed(seed_value) 
california_dt <- california_dt[sample(.N, sample_size_california), ]
california_dt$ocean_proximity <- NULL

# Spatio-Temp Regression task
task_list[["California"]] <- as_task_regr_st(
  california_dt,
  target = "median_house_value",
  coordinate_names = c("longitude", "latitude"),
  id = "California_Housing"
)

# Data Prep : Income
data(Income, package = "SpatialML")
income_df <- as.data.frame(Income)

# Spatio-Temp Regression task
task_list[["Income"]] <- as_task_regr_st(
  income_df,
  target = "Income01",
  coordinate_names = c("X", "Y"),
  id = "Income"
)

# Learners Definition
grf_bw <- 20
grf_ntree <- 50

grf_lrn <- lrn("regr.grf", bw = grf_bw, ntree = grf_ntree, id = "GRF")
featureless_lrn <- lrn("regr.featureless", id = "featureless")
cv_glmnet_lrn <- lrn("regr.cv_glmnet", id = "cv_glmnet")

# KNN
knn_lrn <- lrn("regr.kknn", id = "knn")
knn_lrn$param_set$values$k <- paradox::to_tune(1, 30)
kfoldcv <- mlr3::rsmp("cv")
kfoldcv$param_set$values$folds <- 3

knn_tuned_lrn <- mlr3tuning::auto_tuner(
  learner = knn_lrn,
  tuner = mlr3tuning::tnr("grid_search"),
  resampling = kfoldcv,
  measure = mlr3::msr("regr.rmse")
)

# Learners list 

learners <- list(
  grf_lrn, 
  featureless_lrn, 
  knn_tuned_lrn, 
  cv_glmnet_lrn
)

# 5-fold Cross-Validation
cv <- mlr3::rsmp("cv", folds = 5)
bench_grid <- mlr3::benchmark_grid(
  tasks = task_list, 
  learners = learners, 
  resampling = cv
)
# Config batchtools for SLURM
registry_dir <- "dossier_registry"
if (dir.exists(registry_dir)) {
  unlink(registry_dir, recursive = TRUE)
}

# Create + add benchmark tasks to registry
reg <- batchtools::makeExperimentRegistry(registry_dir)
mlr3batchmark::batchmark(
  bench_grid,
  store_models = FALSE,
  reg=reg
)

job.table <- batchtools::getJobTable(reg=reg)
chunks <- data.frame(job.table, chunk=1)
batchtools::submitJobs(chunks, resources=list(
  walltime = 5*60*60, #seconds
  memory = 8000, #megabytes per cpu
  ncpus=1,
  ntasks=1,
  chunks.as.arrayjobs=TRUE), reg=reg)

# Results retrieval
jobs.after <- batchtools::getJobTable(reg=reg)
ids <- jobs.after[is.na(error), job.id]
bench_results <- mlr3batchmark::reduceResultsBatchmark(ids, reg = reg)
saveRDS(bench_results, "bench_result.rds")

# Compute RMSE scores
score_dt <- bench_results$score(mlr3::msr("regr.rmse"))
cols_to_keep <- c("task_id", "learner_id", "iteration", "regr.rmse")
score_dt_final <- score_dt[, ..cols_to_keep]

# Export .csv
data.table::fwrite(score_dt_final, "bench_scores.csv")