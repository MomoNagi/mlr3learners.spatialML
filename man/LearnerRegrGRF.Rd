\name{LearnerRegrGRF}
\alias{LearnerRegrGRF}
\title{Geographically Weighted Random Forest Learner}
\description{
  Geographically Weighted Random Forest for regression.
  Calls SpatialML::grf() from the SpatialML package.
}
\value{
  An object of type LearnerRegrGRF (inheriting from mlr3::LearnerRegr).
}
\author{Manh Hung LE}
\examples{
  library(mlr3)
  library(mlr3spatiotempcv)
  library(mlr3learners.spatialML)
  task_data <- mlr3::tsk("california_housing")$data()
  task_data <- task_data[complete.cases(task_data), ][1:100, ]
  task_data$ocean_proximity <- NULL
  task <- as_task_regr_st(task_data, target = "median_house_value",
    coordinate_names = c("longitude", "latitude"))
  learner <- lrn("regr.grf", bw = 20, ntree = 10)
  learner$train(task)
  pred <- learner$predict(task)
}
