# =============================================================================
# Preliminary Regression Results
# =============================================================================
# Input : data/psid_panel_long.csv
# Output: output/table_regression.tex
# =============================================================================

# --- 0. Packages -------------------------------------------------------------
library(dplyr)
library(tidyr)
library(stargazer)
library(lmtest)
library(sandwich)

# --- 1. Load data ------------------------------------------------------------
panel <- read.csv("data/psid_analysis_ready.csv")


# --- 2 Regression sample: age 50+, key variables non-missing -----------------
reg_sample <- panel %>%
  filter(
    age >= 50,
    !is.na(k6_distress),
    !is.na(life_satisfaction),
    !is.na(wage_hist_mean),
    !is.na(cv_emp),
    !is.na(employed),
    !is.na(health),
    !is.na(age)
  ) %>%
  mutate(year_factor = as.factor(year))



# --- 3. Regressions ----------------------------------------------------------

# Specification 1: K6 ~ wage_hist_mean + controls
m1 <- lm(k6_distress ~ wage_hist_mean + age + employed + health + year_factor,
         data = reg_sample)

# Specification 2: K6 ~ cv_emp + controls
m2 <- lm(k6_distress ~ cv_emp + age + employed + health + year_factor,
         data = reg_sample)

# Specification 3: life_satisfaction ~ wage_hist_mean + controls
m3 <- lm(life_satisfaction ~ wage_hist_mean + age + employed + health + year_factor,
         data = reg_sample)

# Specification 4: life_satisfaction ~ cv_emp + controls
m4 <- lm(life_satisfaction ~ cv_emp + age + employed + health + year_factor,
         data = reg_sample)

# Robust standard errors (clustered by person)
se1 <- sqrt(diag(vcovCL(m1, cluster = ~person_id)))
se2 <- sqrt(diag(vcovCL(m2, cluster = ~person_id)))
se3 <- sqrt(diag(vcovCL(m3, cluster = ~person_id)))
se4 <- sqrt(diag(vcovCL(m4, cluster = ~person_id)))

# --- 4. Output ---------------------------------------------------------------
if (!dir.exists("output")) dir.create("output")

stargazer(
  m1, m2, m3, m4,
  type             = "latex",
  out              = "output/table_regression.tex",
  se               = list(se1, se2, se3, se4),
  title            = "Preliminary OLS Results (Age 50+)",
  dep.var.labels   = c("K6 Distress", "Life Satisfaction"),
  covariate.labels = c("Mean real wage (hist.)", "CV employment"),
  keep             = c("wage_hist_mean", "cv_emp"),
  omit             = "year_factor",
  add.lines        = list(c("Controls", "Yes", "Yes", "Yes", "Yes"),
                          c("Year FE", "Yes", "Yes", "Yes", "Yes")),
  omit.stat        = c("f", "ser"),
  digits           = 3,
  no.space         = TRUE,
  float            = FALSE,
  notes = "Robust SE clustered by individual in parentheses.",  notes.align      = "l",
  column.sep.width = "1pt"
)

message("End code Estimation")
