library(bench)

cvr_files <- fs::dir_ls("../../data-raw/json", regexp = "Cvr")

bench::mark(
  extract_cvr(cvr_files)
)
