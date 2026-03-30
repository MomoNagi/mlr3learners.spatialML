library(testthat)
library(mlr3)
library(mlr3spatial)
library(data.table)

test_that("testing regr.grf", {
    set.seed(1)

    n <- 50
    task_dt <- data.table(
        y = rnorm(n),
        X = runif(n),
        coord_x = runif(n, -5, 5),
        coord_y = runif(n, 40, 50)
    )

    task <- TaskRegr$new(id = "test", backend = task_dt, target = "y")

    task$col_roles$feature <- "X"
    task$col_roles$coordinate <- c("coord_x", "coord_y")

    learner <- lrn("regr.grf", bw = 20, ntree = 10)
    expect_error(learner$train(task), NA)
    
    pred <- learner$predict(task)

    expect_numeric(pred$response, len = n, any.missing = FALSE)

})