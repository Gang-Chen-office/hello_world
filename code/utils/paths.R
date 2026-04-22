project_root <- function() {
  if (requireNamespace("here", quietly = TRUE)) {
    return(normalizePath(here::here(), winslash = "/", mustWork = FALSE))
  }

  normalizePath(getwd(), winslash = "/", mustWork = FALSE)
}

path_dir <- function(...) {
  file.path(project_root(), ...)
}

ensure_project_dirs <- function() {
  dirs <- c(
    path_dir("data", "raw"),
    path_dir("data", "interim"),
    path_dir("data", "processed"),
    path_dir("output", "tables"),
    path_dir("output", "figures"),
    path_dir("output", "logs"),
    path_dir("paper"),
    path_dir("docs")
  )

  fs::dir_create(dirs)
  invisible(dirs)
}

log_file_path <- function() {
  path_dir("output", "logs", "pipeline.log")
}

log_message <- function(message, level = "INFO") {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  line <- sprintf("[%s] [%s] %s", timestamp, level, message)

  cat(line, "\n")
  write(line, file = log_file_path(), append = TRUE)
  invisible(line)
}

write_if_changed <- function(path, contents) {
  if (file.exists(path)) {
    existing <- paste(readLines(path, warn = FALSE), collapse = "\n")
    if (identical(existing, contents)) {
      return(invisible(FALSE))
    }
  }

  writeLines(contents, con = path, useBytes = TRUE)
  invisible(TRUE)
}

save_rds <- function(object, path) {
  saveRDS(object, file = path)
  invisible(path)
}

read_rds_if_exists <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }

  readRDS(path)
}
