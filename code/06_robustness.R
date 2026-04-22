source(file.path("code", "00_setup.R"))

winsorize <- function(x, probs = c(0.01, 0.99)) {
  bounds <- stats::quantile(x, probs = probs, na.rm = TRUE)
  pmin(pmax(x, bounds[[1]]), bounds[[2]])
}

grunfeld_analysis <- readRDS(path_dir("data", "processed", "grunfeld_analysis.rds"))

robustness_data <- grunfeld_analysis |>
  dplyr::mutate(
    log_value_winsor = winsorize(log_value),
    log_capital_winsor = winsorize(log_capital)
  )

robustness_models <- list(
  "Winsorized FE" = fixest::feols(
    log_invest ~ log_value_winsor + log_capital_winsor | firm + year,
    data = robustness_data,
    vcov = ~firm
  )
)

robustness_results <- list(
  models = robustness_models,
  notes = c(
    "Winsorized FE uses 1% and 99% winsorized log covariates.",
    "Standard errors are clustered by firm."
  )
)

save_rds(robustness_results, path_dir("data", "processed", "robustness_models.rds"))
log_message("Robustness models saved.")
