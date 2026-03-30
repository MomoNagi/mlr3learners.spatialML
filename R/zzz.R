register_mlr3 = function() {
  dict = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  dict$add("regr.grf", LearnerRegrGRF)
}

.onLoad = function(libname, pkgname) {
  mlr3misc::register_namespace_callback(pkgname, "mlr3", register_mlr3)
}

mlr3misc::leanify_package()