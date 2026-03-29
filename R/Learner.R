#' @title Geographically Weighted Random Forest Learner
#' @author Manh Hung LE
#' @name LearnerRegrGRF
#'
#' @description
#' Geographically Weighted Random Forest for regression.
#' Calls `SpatialML::grf()` from the SpatialML package.
#'
#' @export
LearnerRegrGRF = R6Class("LearnerRegrGRF",
    inherit = LearnerRegr,

    public = list(

        initialize = function() {
            ps = ps(
                bw = p_dbl(lower = 0, tags = "train"),
                ntree = p_int(default = 500L, lower = 1L, tags = "train"),
                mtry = p_int(lower = 1L, tags = "train"),
                nodesize = p_int(default = 5L, lower = 1L, tags = "train"),
                maxnodes = p_int(lower = 1L, tags = "train")
            )
                
            super$initialize(
                id = "regr.grf",
                packages = "SpatialML",
                feature_types = c("integer", "numeric"),
                predict_types = "response",
                param_set = ps,
                properties = c("importance", "oob_error"),
                label = "Geographically Weighted Random Forest"
            )
        },

        importance = function() {
            if (is.null(self$model)) {
                stopf("No model stored")
            }
            imp = self$model$Local.Variable.Importance
            scores = colMeans(imp)
            sort(stats::setNames(scores, names(scores)), decreasing = TRUE)
        },

        oob_error = function() {
            if (is.null(self$model)) {
                stopf("No model stored")
            }
            self$model$Global.Model$prediction.error
        }
    ),

    private = list(
        .train = function(task) {
            pars = self$param_set$get_values(tags = "train")
            
            formula = task$formula()
            data = task$data()
            coords = task$coordinates()

            if (!is.null(pars$importance)) {
                pars$importance = NULL
            }

            invoke(grf,
                formula = formula,
                dframe = data,
                coords = coords,
                bw = pars$bw,
                .args = pars
            )
        },

        .predict = function(task) {
            pars = self$param_set$get_values(tags = "predict")
            newdata = ordered_features(task, self)
            coords_new = task$coordinates()

            pred = invoke(predict, self$model,
                new.dframe = newdata,
                new.coords = coords_new,
                .args = pars
            )

            list(response = pred)
        }
    )
)

.extralrns_dict$add("regr.grf", LearnerRegrGRF)