library(ggplot2)
library(data.table)

# Load benchmark results from the csv
results_dt <- fread("bench_scores.csv")

# Remove 'regr' prefix from learner IDs
results_dt[, algorithm := gsub("regr.", "", learner_id, fixed = TRUE)]
results_dt[, dataset := task_id]
results_dt[, rmse := regr.rmse]

# Rank algorithms by their mean RMSE to identify the top performers on each dataset
algo_performance_order <- results_dt[, .(m = mean(rmse)), by = algorithm][order(-m), algorithm]
results_dt[, algorithm := factor(algorithm, levels = algo_performance_order)]

# Define dataset order for better view
results_dt[, dataset := factor(dataset, levels = c("Income", "California_Housing"))]

# Visualize the distribution of RMSE scores across all learners
plot1 <- ggplot(results_dt, aes(x = rmse, y = algorithm)) +
  geom_point(
    shape = 21,
    size = 2,
    fill = "white",
    color = "black",
    stroke = 1
  ) +
  labs(
    x = "RMSE",
    y = "Algorithm"
  )

plot2 <- ggplot(results_dt,  aes(x = rmse, y = algorithm)) +
    geom_point(
    shape = 21,
    size = 2,
    fill = "white",
    color = "black",
    stroke = 1
  ) +
  facet_grid(dataset ~ .) +
  labs(
    x = "RMSE",
    y = "Algorithm"
  )

ggsave("graphique1.png", plot1, width = 8, height = 6)
ggsave("graphique2.png", plot2, width = 8, height = 6)