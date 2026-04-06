library(ggplot2)
library(data.table)

results_dt <- fread("bench_scores.csv")

results_dt[, learner_id := gsub("regr.", "", learner_id, fixed = TRUE)]
results_dt[, dataset := task_id]
results_dt[, rmse := regr.rmse]

# exporting csv
export_csv <- results_dt[, .(
  mean_mse = mean(rmse^2)
), by = .(task_id, learner_id)]

export_csv <- export_csv[order(task_id, mean_mse)]

write.csv(export_csv, "benchmark_results_summary.csv", row.names = FALSE)