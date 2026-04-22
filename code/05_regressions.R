source(file.path("code", "00_setup.R"))

grunfeld_analysis <- readRDS(path_dir("data", "processed", "grunfeld_analysis.rds"))

grunfeld_models <- list(
  "OLS" = fixest::feols(
    log_invest ~ log_value + log_capital,
    data = grunfeld_analysis,
    vcov = "hetero"
  ),
  "Firm + Year FE" = fixest::feols(
    log_invest ~ log_value + log_capital | firm + year,
    data = grunfeld_analysis,
    vcov = ~firm
  )
)

did_models <- NULL
did_path <- path_dir("data", "processed", "card_krueger_analysis.rds")

if (file.exists(did_path)) {
  did_data <- readRDS(did_path)

  did_models <- list(
    "DID" = fixest::feols(
      employment ~ treated + post + treated_post,
      data = did_data,
      vcov = "hetero"
    )
  )

  log_message("Estimated DID example model.")
} else {
  log_message("No DID analysis data found. Main regression script skipped the DID model.", level = "WARN")
}

main_results <- list(
  grunfeld_models = grunfeld_models,
  did_models = did_models,
  notes = list(
    grunfeld = c(
      "OLS uses heteroskedasticity-robust standard errors.",
      "Firm + Year FE includes firm and year fixed effects with firm-clustered standard errors."
    ),
    did = c(
      "DID is estimated only when CardKrueger analysis data is available.",
      "The example DID model uses heteroskedasticity-robust standard errors."
    )
  )
)

save_rds(main_results, path_dir("data", "processed", "main_models.rds"))
log_message("Main regression models saved.")
