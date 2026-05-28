library(here)
library(readxl)
library(tidyverse)

# ── 1. Peek at raw structure ──────────────────────────────────────────────────
cat("=== Sheet names ===\n")
print(excel_sheets(here("data/EXP-SA-expenditure-GDP.xlsx")))

cat("\n=== First 10 rows (no col names) ===\n")
raw <- read_excel(here("data/EXP-SA-expenditure-GDP.xlsx"),
                  n_max = 10, col_names = FALSE)
print(raw, width = Inf)

# ── 2. Load with sensible skip (adjust if needed after seeing raw above) ──────
#    Try skip = 3 first; change if the peek shows a different header depth
df_expsa <- read_excel(here("data/EXP-SA-expenditure-GDP.xlsx"),
                       skip = 3, col_names = FALSE,
                       na = c("n.a.", "NA", ""))

cat("\n=== Dimensions ===\n")
cat("Rows:", nrow(df_expsa), " Cols:", ncol(df_expsa), "\n")

cat("\n=== First 6 rows after skip ===\n")
print(head(df_expsa), width = Inf)

# ── 3. Check join keys against clean_dataset.csv ─────────────────────────────
df_clean <- read.csv(here("data/clean_dataset.csv"))

# Assume cols 3 & 4 are country_code and year in EXP-SA (adjust if needed)
expsa_codes <- df_expsa[[3]] |> na.omit() |> unique() |> sort()
expsa_years <- df_expsa[[6]] |> na.omit() |> unique() |> sort()

clean_codes  <- df_clean$country_code |> unique() |> sort()
clean_years  <- df_clean$year         |> unique() |> sort()

cat("\n=== Country codes in EXP-SA (sample) ===\n")
print(head(expsa_codes, 20))

cat("\n=== Years in EXP-SA ===\n")
print(expsa_years)

cat("\n=== Country codes in clean_dataset (sample) ===\n")
print(head(clean_codes, 20))

cat("\n=== Years in clean_dataset ===\n")
print(clean_years)

cat("\n=== Overlapping country codes ===\n")
overlap_codes <- intersect(expsa_codes, clean_codes)
cat("Count:", length(overlap_codes), "\n")
print(overlap_codes)

cat("\n=== In clean_dataset but NOT in EXP-SA ===\n")
print(setdiff(clean_codes, expsa_codes))

cat("\n=== In EXP-SA but NOT in clean_dataset ===\n")
print(setdiff(expsa_codes, clean_codes))
