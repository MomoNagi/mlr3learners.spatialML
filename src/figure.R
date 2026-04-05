library(ggplot2)
library(data.table)

results_dt <- fread("bench_scores.csv")

results_dt[, algorithm := gsub("regr.", "", learner_id, fixed = TRUE)]
results_dt[, dataset := task_id]
results_dt[, rmse := regr.rmse]

# On ordonne les algorithmes par performance moyenne décroissante
algo_order <- results_dt[, .(m = mean(rmse)), by = algorithm][order(-m), algorithm]
results_dt[, algorithm := factor(algorithm, levels = algo_order)]

# Inversement de l'ordre pour avoir Income au dessus
results_dt[, dataset := factor(dataset, levels = c("Income", "California_Housing"))]

# Affichage
plot1 <- ggplot(results_dt, aes(x = rmse, y = algorithm)) +
  geom_point(
    shape = 21,
    size = 2,
    fill = "white",
    color = "black",
    stroke = 1
  ) +
  labs(x = "RMSE", y = "learner_id")

ggsave("graphique1.png", plot1, width = 8, height = 6)

plot2 <- ggplot(results_dt,  aes(x = rmse, y = algorithm)) +
    geom_point(
    shape = 21,
    size = 2,
    fill = "white",
    color = "black",
    stroke = 1
  ) +
  facet_grid(dataset ~ .) +
  labs(x = "RMSE", y = "learner_id")

ggsave("graphique2.png", plot2, width = 8, height = 6)