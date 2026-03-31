# mlr3learners.spatialML

This R package provides an interface to the `spatialML` package for the `mlr3` ecosystem.

It implements the Geographically Weighted Random Forest (GRF) algorithm for regression tasks.

## Installation

To install it, you can use this command :

```r
# install.packages("devtools")
devtools::install_github("MomoNagi/mlr3learners.spatialML")
```

## Usage
This package provides the regr.grf learner for mlr3. It requires a TaskRegrST (spatiotemporal task) from the mlr3spatiotempcv package to access coordinates x,y.

```r
library(mlr3)
library(mlr3spatiotempcv)
library(mlr3learners.spatialML)

learner <- lrn("regr.grf", bw = 20, ntree = 10)
learner$train(task)
pred <- learner$predict(task)
```

## Related work

* [Course wiki](https://github.com/tdhock/2026-01-aa-grande-echelle/wiki/projets)
* [SpatialML package](https://cran.r-project.org/package=SpatialML)