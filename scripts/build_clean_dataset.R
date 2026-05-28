library(here)
library(tidyverse)
library(readxl)

# --- Table 7: Coverage of 12 Programs ---
col_names_t7 <- c(
  "note", "blank2",
  "region", "country_code",
  "income_class", "country", "year",
  "sep1",
  "si_contrib_pensions_pq",    "si_contrib_pensions_total",
  "si_other_insurance_pq",     "si_other_insurance_total",
  "sep2",
  "lm_passive_pq",             "lm_passive_total",
  "lm_active_pq",              "lm_active_total",
  "sep3",
  "uct_pq",                    "uct_total",
  "cct_pq",                    "cct_total",
  "sa_noncontrib_pensions_pq", "sa_noncontrib_pensions_total",
  "sa_food_inkind_pq",         "sa_food_inkind_total",
  "sa_school_feeding_pq",      "sa_school_feeding_total",
  "sa_public_works_pq",        "sa_public_works_total",
  "sa_fee_waivers_pq",         "sa_fee_waivers_total",
  "sa_other_pq",               "sa_other_total"
)

df_t7 <- read_excel(
  here("data/PER-Table7-Coverage12-Programs.xlsx"),
  skip = 4,
  col_names = col_names_t7,
  na = c("n.a.", "NA", "")
) |>
  filter(!is.na(country_code)) |>
  select(-note, -blank2, -starts_with("sep")) |>
  mutate(year = as.integer(year),
         across(si_contrib_pensions_pq:sa_other_total, as.numeric))

# --- Table 1: Key Indicators ---
col_names_t1 <- c(
  "note", "blank2",
  "region", "country_code", "income_class", "country", "year",
  "coverage_pq", "coverage_total",
  "benefit_incidence_pq",
  "avg_transfer_total",
  "adequacy_pq", "adequacy_total",
  "gini_reduction", "headcount_reduction",
  "poverty_gap_reduction",
  "benefit_cost_ratio"
)

df_t1 <- read_excel(
  here("data/PER-Table1-Key-Indicators.xlsx"),
  skip = 3,
  col_names = col_names_t1,
  na = c("n.a.", "NA", "")
) |>
  filter(!is.na(country_code)) |>
  select(-note, -blank2) |>
  mutate(year = as.integer(year),
         across(coverage_pq:benefit_cost_ratio, as.numeric))

# --- Join and select final variables ---
df_analysis <- df_t7 |>
  select(country_code, country, region, income_class, year,
         uct_pq, uct_total, cct_pq, cct_total,
         school_feeding_pq    = sa_school_feeding_pq,
         school_feeding_total = sa_school_feeding_total,
         public_works_pq      = sa_public_works_pq,
         public_works_total   = sa_public_works_total,
         social_care_pq       = sa_other_pq,
         social_care_total    = sa_other_total) |>
  left_join(
    df_t1 |> select(country_code, year, poverty_gap_reduction,
                    avg_transfer_amount = avg_transfer_total),
    by = c("country_code", "year")
  ) |>
  filter(!is.na(poverty_gap_reduction))

glimpse(df_analysis)
cat("Rows in df_analysis:", nrow(df_analysis), "\n")

write.csv(df_analysis, here("data/clean_dataset.csv"), row.names = FALSE)
cat("clean_dataset.csv written.\n")

# Drop rows where both UCT and CCT are entirely NA
df_analysis_clean <- df_analysis |>
  filter(
    (!is.na(uct_pq) | !is.na(uct_total)) &
      (!is.na(cct_pq) | !is.na(cct_total))
  ) |>
  mutate(across(c(school_feeding_pq, school_feeding_total,
                  public_works_pq,   public_works_total,
                  social_care_pq,    social_care_total),
                ~ replace_na(., 0)))

glimpse(df_analysis_clean)
cat("Rows in df_analysis_clean:", nrow(df_analysis_clean), "\n")

write.csv(df_analysis_clean,
          here("data/clean_dataset_uct_cct.csv"),
          row.names = FALSE)
cat("clean_dataset_uct_cct.csv written.\n")
