# Codex Context for Positron: Simple Research Workflow

## Purpose
This repository is for an empirical academic paper. Work like a careful research assistant building a reproducible path from raw data to final tables and figures.

Use **R** by default unless a file or instruction clearly requires Python. Prefer code that is easy to read, rerun, and modify in **Positron**.

## Core Rules
- Never overwrite raw data.
- Use relative paths only.
- Keep scripts idempotent so reruns produce the same outputs.
- Separate raw data, cleaned data, analysis code, outputs, and paper files.
- Prefer simple, transparent steps over clever shortcuts.
- Comment assumptions when something is uncertain.

## Suggested Structure

```text
data/
  raw/
  interim/
  processed/
code/
  00_setup.R
  01_download_data.R
  02_clean_data.R
  03_construct_variables.R
  04_descriptive_stats.R
  05_regressions.R
  06_robustness.R
  07_make_outputs.R
  utils/
output/
  tables/
  figures/
  logs/
paper/
docs/
```

## Simple Workflow
Follow this order unless the researcher asks for something different.

1. **Set up the project**
   - Load packages.
   - Create folders if missing.
   - Define shared paths, themes, and helper functions.

2. **Get the data**
   - Download or import data into `data/raw/`.
   - Keep an untouched copy of the original file.
   - Record the source and download date.

3. **Clean the data**
   - Standardize names.
   - Fix types, duplicates, missing values, and obvious inconsistencies.
   - Save cleaned data to `data/interim/`.

4. **Build analysis data**
   - Create analysis variables in a separate script.
   - Keep transformations explicit.
   - Save final analysis-ready data to `data/processed/`.

5. **Run analysis and export outputs**
   - Produce descriptive statistics first.
   - Run main regressions.
   - Run robustness checks.
   - Export tables and figures to `output/`.

## Default Example Data
Use public built-in datasets so the workflow stays reproducible.

- For OLS and panel examples, use `Grunfeld` from `plm`.
- For DID examples, use `CardKrueger` from `AER` when available.

## Preferred Packages
- Data: `tidyverse`, `data.table`, `janitor`, `arrow`
- Regressions: `fixest`, `plm`, `broom`, `modelsummary`
- Tables and figures: `gt`, `tinytable`, `ggplot2`, `patchwork`
- Project setup: `here`, `fs`, `renv`

Prefer `fixest` for most regressions.

## Coding Conventions
- Use snake_case for objects and filenames.
- Use one script per stage of the pipeline.
- Each script should read inputs from the previous stage and write outputs to a fixed location.
- Avoid hidden state in the global environment.
- Do not rely on manual clicks inside Positron.

## Regression Expectations
- Report sample size.
- State fixed effects used.
- State clustering level.
- Make variable definitions clear.
- For DID, define `treated`, `post`, and the treatment interaction explicitly.

## Output Conventions
- Put tables in `output/tables/`.
- Put figures in `output/figures/`.
- Use stable, descriptive filenames such as:
  - `table_1_summary_statistics.tex`
  - `table_2_main_results.tex`
  - `table_a1_robustness.tex`
  - `figure_1_distribution.pdf`
  - `figure_2_main_relationship.pdf`

## What Codex Should Do
When helping in this repo:
1. Inspect the existing structure first.
2. Preserve current naming conventions when they already exist.
3. Make small, testable edits.
4. Keep outputs reusable, not just printed to the console.
5. Document assumptions briefly in code comments or a short note.

## What to Avoid
- Do not mix raw-data cleaning and regression code in one large script.
- Do not hard-code machine-specific paths.
- Do not silently drop observations without reporting counts.
- Do not hide transformations.
- Do not save paper tables as screenshots.

## Minimal Script Responsibilities
- `00_setup.R`: packages, folders, paths, shared defaults
- `01_download_data.R`: import or download raw data
- `02_clean_data.R`: basic cleaning and validation
- `03_construct_variables.R`: create final analysis variables
- `04_descriptive_stats.R`: sample counts and summary tables
- `05_regressions.R`: main models
- `06_robustness.R`: alternative specifications and checks
- `07_make_outputs.R`: final tables and figures

## Suggested Run Order

```r
source("code/00_setup.R")
source("code/01_download_data.R")
source("code/02_clean_data.R")
source("code/03_construct_variables.R")
source("code/04_descriptive_stats.R")
source("code/05_regressions.R")
source("code/06_robustness.R")
source("code/07_make_outputs.R")
```

## Quality Check
Before calling the work complete, confirm that:
- scripts run from top to bottom without manual intervention,
- outputs land in the expected folders,
- tables and figures are clearly labeled,
- code is easy to adapt when real data replace the example data.
