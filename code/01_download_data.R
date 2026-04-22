source(file.path("code", "00_setup.R"))

write_raw_csv <- function(data, path) {
  temp_path <- tempfile(fileext = ".csv")
  on.exit(unlink(temp_path), add = TRUE)

  readr::write_csv(data, temp_path)

  if (file.exists(path)) {
    existing_hash <- unname(tools::md5sum(path))
    new_hash <- unname(tools::md5sum(temp_path))

    if (!identical(existing_hash, new_hash)) {
      stop(
        sprintf(
          "Refusing to overwrite protected raw file because it differs from the bundled source: %s",
          path
        ),
        call. = FALSE
      )
    }
  }

  file.copy(temp_path, path, overwrite = TRUE)
  invisible(path)
}

grunfeld_raw <- as.data.frame(plm::Grunfeld)
grunfeld_raw_path <- path_dir("data", "raw", "grunfeld_raw.csv")
write_raw_csv(grunfeld_raw, grunfeld_raw_path)
log_message("Saved raw Grunfeld data.")

card_krueger_raw <- NULL
card_krueger_raw_path <- path_dir("data", "raw", "card_krueger_raw.csv")

if (requireNamespace("AER", quietly = TRUE)) {
  did_env <- new.env(parent = emptyenv())
  utils::data("CardKrueger", package = "AER", envir = did_env)

  if (exists("CardKrueger", envir = did_env, inherits = FALSE)) {
    card_krueger_raw <- as.data.frame(get("CardKrueger", envir = did_env))
    write_raw_csv(card_krueger_raw, card_krueger_raw_path)
    log_message("Saved raw CardKrueger data.")
  } else {
    log_message("AER is installed, but CardKrueger was not found. DID path will be skipped.", level = "WARN")
  }
} else {
  log_message("AER is not installed. DID path will be skipped.", level = "WARN")
}

data_source_lines <- c(
  "# Data sources",
  "",
  sprintf(
    "- `plm::Grunfeld`: built-in panel dataset saved to `%s` on %s.",
    gsub("\\\\", "/", grunfeld_raw_path),
    Sys.Date()
  ),
  if (!is.null(card_krueger_raw)) {
    sprintf(
      "- `AER::CardKrueger`: built-in DID example saved to `%s` on %s.",
      gsub("\\\\", "/", card_krueger_raw_path),
      Sys.Date()
    )
  } else {
    sprintf("- `AER::CardKrueger`: not available in this environment on %s.", Sys.Date())
  }
)

write_if_changed(
  path_dir("docs", "data_sources.md"),
  paste(data_source_lines, collapse = "\n")
)

log_message("Data source notes updated.")
