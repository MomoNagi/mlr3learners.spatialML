library(testthat)
library(mlr3)
library(mlr3spatiotempcv)

test_that("testing regr.grf", {
    set.seed(1)
  
    task_data <- mlr3::tsk("california_housing")$data()
    task_data <- task_data[complete.cases(task_data), ][1:100,]
    task_data$ocean_proximity <- NULL

    task <- as_task_regr_st(task_data, target = "median_house_value", coordinate_names = c("longitude", "latitude"))

    learner <- lrn("regr.grf", bw = 20, ntree = 10)

    learner$train(task)
    pred <- learner$predict(task)

    expect_true(is.numeric(pred$response))
    expect_equal(length(pred$response), nrow(task_data))
})