# Implement Runnable Research Example Repo

## Summary
Convert the current repo from a single workflow note into a runnable R-based example project that follows `example_workflow.md`. Build a minimal but working pipeline around the `plm::Grunfeld` dataset, make the DID example optional via `AER::CardKrueger`, and replace the current plain `README` with a standard `README.md` that explains setup, run order, and outputs.

## Key Changes
- Replace the current top-level `README` with `README.md`, and document:
  - project purpose,
  - folder layout,
  - required packages,
  - script run order,
  - expected outputs,
  - note that DID outputs are conditional on `AER` availability.
- Create the repo structure described by the workflow:
  - `data/raw`, `data/interim`, `data/processed`
  - `code/utils`
  - `output/tables`, `output/figures`, `output/logs`
  - `paper`, `docs`
- Add a compact, runnable script pipeline:
  - `code/00_setup.R`
  - `code/01_download_data.R`
  - `code/02_clean_data.R`
  - `code/03_construct_variables.R`
  - `code/04_descriptive_stats.R`
  - `code/05_regressions.R`
  - `code/06_robustness.R`
  - `code/07_make_outputs.R`
  - `code/utils/paths.R`
- Define the script contracts so each stage is deterministic:
  - `00_setup.R`: load/validate packages, create folders, define shared paths and simple logging/theme helpers
  - `01_download_data.R`: save raw copies of `Grunfeld` and, if available, `CardKrueger`; write `docs/data_sources.md`
  - `02_clean_data.R`: standardize names, coerce types, report duplicates/missingness, save `.rds` clean datasets to `data/interim`
  - `03_construct_variables.R`: create `log_*` variables and panel identifiers for Grunfeld; create `treated`, `post`, `treated_post` for DID only when CardKrueger data exists; save processed `.rds` files
  - `04_descriptive_stats.R`: generate sample counts and summary statistics; save machine-readable summaries plus `table_1_summary_statistics`
  - `05_regressions.R`: run main OLS and panel models on Grunfeld; run DID only if processed DID data exists; save model objects for downstream export
  - `06_robustness.R`: rerun the main Grunfeld models with at least one alternative spec, such as winsorized logs or alternative clustering, and save appendix-ready model objects
  - `07_make_outputs.R`: export final tables and figures from saved artifacts into stable filenames under `output/`
- Keep the implementation intentionally lightweight:
  - Use a small core package set: `here`, `fs`, `janitor`, `dplyr`, `readr`, `ggplot2`, `fixest`, `modelsummary`, `broom`, `plm`
  - Do not initialize `renv` in v1
  - Prefer `.rds` and `.csv` intermediates over parquet to avoid extra setup
- Make the output contract explicit:
  - Always produce Grunfeld-based outputs
  - Only produce DID outputs when `AER::CardKrueger` is available
  - Use stable names like `table_1_summary_statistics`, `table_2_main_results`, `table_a1_robustness`, `figure_1_distribution`, `figure_2_main_relationship`
- Add simple robustness and failure handling:
  - scripts should fail early on missing required packages for the Grunfeld path
  - DID path should degrade gracefully with a logged message rather than breaking the full pipeline
  - reruns should overwrite generated intermediate/output artifacts, but never raw source files once written unless the source content is identical

## Interfaces / Entry Points
- Primary user interface is the sequential `source(...)` run order documented in `README.md` and mirrored in `example_workflow.md`.
- Data artifacts:
  - raw CSVs in `data/raw`
  - clean `.rds` datasets in `data/interim`
  - analysis `.rds` datasets in `data/processed`
  - model objects and summaries saved as reusable files for the final output stage
- No public package/API surface is introduced; the stable contract is the script sequence plus the output file layout.

## Test Plan
- Static repo checks:
  - confirm all expected directories and scripts exist
  - confirm `README.md` matches the implemented script names and run order
  - confirm `README` is removed or superseded, per the replacement decision
- Runtime checks in an R-enabled environment:
  - source scripts in order from `00_setup.R` through `07_make_outputs.R`
  - verify Grunfeld outputs are created in `output/tables` and `output/figures`
  - rerun the full sequence and confirm no manual cleanup is required
  - verify missing/optional DID data path does not break the Grunfeld pipeline
  - if `AER` is installed, verify DID artifacts are also produced
- Content checks:
  - regression tables include sample size and clustering/fixed-effects notes
  - figures have readable labels and deterministic filenames
  - logs or console messages clearly state when optional DID steps are skipped

## Assumptions
- The implementation target is a runnable example repo, not just commented scaffolding.
- `README` should be replaced by a standard `README.md`.
- Grunfeld is the required happy path; CardKrueger is optional and should not be allowed to block the main pipeline.
- Validation cannot be fully executed from the current shell environment because `Rscript` is not available on PATH here, so runtime verification should be performed in Positron or another R-enabled environment after implementation.
