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

california_dt$median_house_value <- scale(california_dt$median_house_value)[, 1]

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
income_df$Income01 <- scale(income_df$Income01)[, 1]

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

bench_results <- mlr3::benchmark(bench_grid, store_models = FALSE)

results_dt <- bench_results$score(mlr3::msr("regr.rmse"))[, let(
  algorithm = gsub("regr.", "", learner_id, fixed = TRUE),
  dataset = task_id,
  rmse = regr.rmse)]

algo_order <- results_dt[, .(m = mean(rmse)), by = algorithm][order(-m), algorithm]
results_dt[, algorithm := factor(algorithm, levels = algo_order)]
results_dt[, dataset := factor(dataset, levels = c("Income", "California_Housing"))]
ggplot(results_dt, aes(x = rmse, y = algorithm)) +
  geom_point(
    shape = 21,
    size = 2,
    fill = "white",
    color = "black",
    stroke = 1
  ) +
  facet_grid(. ~ dataset, scales = "free") +
  labs(
    x = "RMSE",
    y = "Algorithm"
  )