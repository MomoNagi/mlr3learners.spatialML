# mlr3learners.spatialML

[![R-CMD-check](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/check.yaml/badge.svg)](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/check.yaml)
[![test-coverage](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/test-coverage.yaml)
[![codecov](https://codecov.io/gh/MomoNagi/mlr3learners.spatialML/graph/badge.svg?token=NTMNXVKQ9J)](https://codecov.io/gh/MomoNagi/mlr3learners.spatialML)
[![pkgdown](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/pkgdown.yml/badge.svg)](https://github.com/MomoNagi/mlr3learners.spatialML/actions/workflows/pkgdown.yml)
[![Netlify Status](https://api.netlify.com/api/v1/badges/57b9cfe0-5ad6-4579-abb4-11d0c2df9825/deploy-status)](https://mlr3learners-grf.netlify.app/)

This R package provides an interface to the `spatialML` package for the `mlr3` ecosystem.

It implements the Geographically Weighted Random Forest (GRF) algorithm for regression tasks.

## Documentation

The site can be found at : https://mlr3learners-grf.netlify.app/

This site includes API references, usage guides and a detailed performance benchmark (vignettes).

## Installation

To install it, you can use this command :

```r
# Installing SpatialML
install.packages("https://cran.r-project.org/src/contrib/Archive/SpatialML/SpatialML_0.1.6.tar.gz", repos = NULL, type = "source")

# install.packages("remotes")
remotes::install_github("MomoNagi/mlr3learners.spatialML")
```

## Usage

This package provides the regr.grf learner for mlr3. It requires a TaskRegrST (Spatio-Temporal Task) from the mlr3spatiotempcv package to correctly handle spatial coordinates.

```r
library(mlr3)
library(mlr3spatiotempcv)
library(mlr3learners.spatialML)

task <- tsk("california_housing")
learner <- lrn("regr.grf", bw = 20, ntree = 50)
learner$train(task)
pred <- learner$predict(task)
```

## Benchmark results

Performance was evaluated using the **Root Mean Squared Error (RMSE)**. Results are based on a 5-fold cross-validation. Values represent the Mean RMSE (± Standard Deviation).

| Dataset | **GRF** | KNN (Tuned) | CV-Glmnet | Featureless |
| :--- | :--- | :--- | :--- | :--- |
| **California Housing** | 91,628 (±8,849) | 88,497 (±9,489) | **81,158 (±10,974)** | 123,044 (±8,091) |
| **Income** | 1,776 (±146) | **1,630 (±290)** | 1,921 (±469) | 2,929 (±447) |

Note : Lower values indicate better performance. **Bold** values represent the best learner for each task.

We can see that GRF remains competitive with KNN and CVGlmnet. It also stands out as the most stable learner on the *Income* dataset with the lowest standard deviation. Furthermore, its significant outperformance of the *Featureless* baseline confirms its effectiveness.

# Development

This package includes :

- **End-to-End Testing**: Automated test suite ensuring seamless integration between mlr3 and SpatialML
- **Continuous Integration**: Validation via GitHub Actions on every push.
- **Documentation**: Complete API reference and performance vignettes deployed on Netlify.
- **Vignette**: Complete demonstration of the benchmark

## Related work

* [Course wiki](https://github.com/tdhock/2026-01-aa-grande-echelle/wiki/projets)
* [SpatialML (CRAN Archive)](https://cran.r-project.org/src/contrib/Archive/SpatialML/) - Core package for GRF.
* [mlr3spatiotempcv](https://mlr3spatiotempcv.mlr-org.com/) - Required for handling spatial tasks in mlr3.
* [Issue mlr3extralearners #403](https://github.com/mlr-org/mlr3extralearners/issues/403) (SpatialML grf)

## Author

**Manh Hung LE** - [GitHub](https://github.com/MomoNagi)

## Licence

MIT License