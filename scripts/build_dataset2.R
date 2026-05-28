library(here)
library(tidyverse)
library(readxl)

# ── 1. Load EXP-SA ────────────────────────────────────────────────────────────
# Row 1 = title, Row 2 = blank, Row 3 = headers, Row 4+ = data
# skip=2 lets read_excel treat Row 3 as the column header row
df_expsa_raw <- read_excel(
  here("data/EXP-SA-expenditure-GDP.xlsx"),
  skip = 2,
  na   = c("n.a.", "NA", "", "..")   # ".." is also used for missing
)

# Rename to clean snake_case
df_expsa <- df_expsa_raw |>
  rename(
    country_code          = `Country code`,
    country               = `Country name`,
    region_expsa          = `Region`,
    income_class_expsa    = `Income classification`,
    lending_category      = `Lending category`,
    year_range            = `Years`,
    exp_total_sa          = `Total Social Assistance`,
    exp_total_sa_excl_hlt = `Total Social Assistance (excluding non-contributory health services)`,
    exp_cct               = `Conditional cash transfers`,
    exp_uct               = `Unconditional cash transfers`,
    exp_social_pensions   = `Social pensions (non-contributory)`,
    exp_school_feeding    = `School feeding`,
    exp_public_works      = `Public works`,
    exp_food_inkind       = `Food and in-kind transfers`,
    exp_fee_waivers       = `Fee waivers and targeted subsidies`,
    exp_health            = `Non-contributory health services`,
    exp_social_care       = `Social care services`,
    exp_other             = `Other social assistance`
  ) |>
  filter(!is.na(country_code)) |>
  mutate(across(starts_with("exp_"), as.numeric))

cat("EXP-SA rows:", nrow(df_expsa), "\n")
cat("EXP-SA country codes (sample):\n")
print(head(df_expsa$country_code, 20))
cat("EXP-SA year ranges present:\n")
print(unique(df_expsa$year_range))

# ── 2. Filter clean_dataset to 2020–2022 ─────────────────────────────────────
df_clean <- read.csv(here("data/clean_dataset.csv"))

df_clean_2022 <- df_clean |>
  filter(year %in% c(2020, 2021, 2022))

cat("\nclean_dataset rows 2020-2022:", nrow(df_clean_2022), "\n")
cat("Countries in filtered clean_dataset:",
    n_distinct(df_clean_2022$country_code), "\n")

# ── 3. Check overlap before joining ──────────────────────────────────────────
overlap <- intersect(df_clean_2022$country_code, df_expsa$country_code)
cat("\nOverlapping countries:", length(overlap), "\n")
print(sort(overlap))

cat("\nIn clean_dataset 2020-2022 but NOT in EXP-SA:\n")
print(sort(setdiff(df_clean_2022$country_code, df_expsa$country_code)))

# ── 4. Join ───────────────────────────────────────────────────────────────────
# EXP-SA is one row per country (period average); clean_dataset may have
# multiple year rows per country — EXP-SA values will repeat across years
df_dataset2 <- df_clean_2022 |>
  left_join(
    df_expsa |> select(country_code, year_range, starts_with("exp_")),
    by = "country_code"
  )

cat("\nDataset 2 rows:", nrow(df_dataset2), "\n")
cat("Dataset 2 columns:", ncol(df_dataset2), "\n")
glimpse(df_dataset2)

# ── 5. Save ───────────────────────────────────────────────────────────────────
write.csv(df_dataset2, here("data/clean_dataset2.csv"), row.names = FALSE)
cat("\nclean_dataset2.csv saved.\n")
