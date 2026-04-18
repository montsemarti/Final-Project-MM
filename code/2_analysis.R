# =============================================================================
# Variable Construction, Table & Graphs
# =============================================================================
# Input : data/psid_panel_long.csv
# Output:
#   - output/table1a_individual.tex
#   - output/table1b_summary.tex
#   - output/plot1_wage_lifecycle.png
#   - output/plot2_employment_lifecycle.png
# =============================================================================

# --- 0. Packages -------------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(stargazer)

# --- 1. Load data ------------------------------------------------------------
panel <- read.csv("data/psid_panel_long.csv")
cat("Rows:", nrow(panel), "| Unique individuals:", n_distinct(panel$person_id), "\n")

# --- 2. Variable construction ------------------------------------------------

# 2.1 Real wage (nominal -> real, base 2019, CPI-U BLS annual averages)
cpi <- data.frame(
  year = c(1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,
           1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,
           1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,
           1999,2001,2003,2005,2007,2009,2011,2013,2015,2017,
           2019,2021,2023),
  cpi  = c(13.6,14.3,15.2,15.8,16.3,17.3,18.9,20.7,21.9,23.4,
           25.1,27.8,31.4,34.5,36.5,37.6,39.3,40.5,41.3,42.7,
           44.5,46.7,49.3,51.4,53.0,54.5,55.9,57.5,59.3,60.8,
           63.2,65.9,69.5,73.7,78.0,80.6,87.6,91.2,96.0,99.5,
           100.0,108.5,119.1)
)

panel <- panel %>%
  left_join(cpi, by = "year") %>%
  mutate(
    wage_real = ifelse(!is.na(wage) & !is.na(cpi) & cpi > 0,
                       wage * (100 / cpi), NA_real_),
    wage_real = ifelse(wage_real > quantile(wage_real, 0.99, na.rm = TRUE),
                       quantile(wage_real, 0.99, na.rm = TRUE), wage_real)
  )

# 2.2 Employment indicator
panel <- panel %>%
  mutate(employed = if_else(empl_status == 1, 1L, 0L, missing = NA_integer_))

# 2.3 Historical average wage per person (only employed years, wage > 0)
wage_history <- panel %>%
  filter(employed == 1, !is.na(wage_real), wage_real > 0) %>%
  group_by(person_id) %>%
  summarise(
    wage_hist_mean = mean(wage_real, na.rm = TRUE),
    wage_hist_n    = n(),
    .groups = "drop"
  )

panel <- panel %>%
  left_join(wage_history, by = "person_id")

# 2.4 Income quintile (persons with >= 3 observed wage years)
wage_quintile_df <- wage_history %>%
  filter(wage_hist_n >= 3) %>%
  mutate(wage_quintile = ntile(wage_hist_mean, 5))

panel <- panel %>%
  left_join(wage_quintile_df %>% select(person_id, wage_quintile),
            by = "person_id")

# 2.5 Later life subsample
later_life <- panel %>% filter(age >= 50)


# --- 3. Output directory -----------------------------------------------------
if (!dir.exists("output")) dir.create("output")

# Shared palette and theme
quintile_palette <- c("#a8d1f5","#5aaee8","#2176ae","#164f7a","#0a2540")
quintile_labels  <- c("Q1 (lowest)","Q2","Q3","Q4","Q5 (highest)")

theme_psid <- theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "gray40", size = 10),
    plot.caption    = element_text(color = "gray50", size = 8),
    legend.position = "right"
  )

# =============================================================================
# TABLE 1A — Individual-level summary
# =============================================================================
panel_a <- panel %>%
  distinct(person_id, .keep_all = TRUE) %>%
  filter(!is.na(wage_hist_mean)) %>%
  select(wage_hist_mean, wage_hist_n, sex) %>%
  mutate(female = if_else(sex == 2, 1L, 0L, missing = NA_integer_)) %>%
  select(wage_hist_mean, wage_hist_n, female)

stargazer(
  as.data.frame(panel_a),
  type             = "latex",
  out              = "output/table1a_individual.tex",
  title            = "Individual-level Summary (Full Sample)",
  covariate.labels = c("Mean real wage (USD 2019)", "Years of wage observed", "Female (=1)"),
  summary.stat     = c("n", "mean", "sd", "min", "max"),
  digits           = 2,
  no.space         = TRUE,
  float            = FALSE
)


# =============================================================================
# TABLE 1B — CV employment, K6 and life satisfaction by quintile
# =============================================================================

# CV de empleo por persona (age 20-65)
cv_employment <- panel %>%
  filter(!is.na(wage_quintile), !is.na(employed), age >= 20, age <= 65) %>%
  group_by(person_id, wage_quintile) %>%
  summarise(
    mean_emp = mean(employed, na.rm = TRUE),
    sd_emp   = sd(employed, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  filter(!is.na(sd_emp), mean_emp > 0) %>%
  mutate(cv_emp = sd_emp / mean_emp) %>%
  group_by(wage_quintile) %>%
  summarise(
    mean_cv = round(mean(cv_emp, na.rm = TRUE), 3),
    .groups = "drop"
  )

# K6 y life satisfaction a 50+
outcomes_50 <- panel %>%
  filter(!is.na(wage_quintile), age >= 50) %>%
  group_by(wage_quintile) %>%
  summarise(
    mean_k6      = round(mean(k6_distress, na.rm = TRUE), 2),
    mean_lifesat = round(mean(life_satisfaction, na.rm = TRUE), 2),
    .groups = "drop"
  )

# Combinar
table_b <- cv_employment %>%
  left_join(outcomes_50, by = "wage_quintile") %>%
  arrange(wage_quintile) %>%
  mutate(wage_quintile = quintile_labels)

# LaTeX
sink("output/table1b_summary.tex")
cat("\\begin{tabular}{lrrr}\n")
cat("\\toprule\n")
cat("\\textbf{Quintile} & \\textbf{CV Employment (20--65)} & \\textbf{K6 (50+)} & \\textbf{Life Sat. (50+)} \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table_b)) {
  cat(sprintf("%s & %.3f & %.2f & %.2f \\\\\n",
              table_b$wage_quintile[i],
              table_b$mean_cv[i],
              table_b$mean_k6[i],
              table_b$mean_lifesat[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
sink()


# =============================================================================
# PLOT 1 — Real wage lifecycle by income quintile
# =============================================================================
plot1_data <- panel %>%
  filter(!is.na(wage_quintile), !is.na(age), !is.na(wage_real),
         age >= 20, age <= 65, wage_real > 0, employed == 1) %>%
  mutate(age_bin = floor(age / 2) * 2) %>%
  group_by(wage_quintile, age_bin) %>%
  summarise(mean_wage = mean(wage_real, na.rm = TRUE), n = n(), .groups = "drop") %>%
  filter(n >= 30)

p1 <- ggplot(plot1_data,
             aes(x = age_bin, y = mean_wage,
                 color = factor(wage_quintile),
                 group = factor(wage_quintile))) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  scale_color_manual(values = quintile_palette, labels = quintile_labels,
                     name = "Income quintile") +
  scale_y_continuous(labels = dollar_format(prefix = "USD ")) +
  scale_x_continuous(breaks = seq(20, 65, 5)) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "gray50") +
  annotate("text", x = 50.5, y = max(plot1_data$mean_wage, na.rm = TRUE) * 0.97,
           label = "Career twilight (50+)", hjust = 0, size = 3.2, color = "gray40") +
  labs(
    title    = "Real wage lifecycle by historical income quintile",
    subtitle = "2019 USD — mean by 2-year age bins",
    x        = "Age",
    y        = "Mean real hourly wage (USD)",
    caption  = "Source: PSID 1968–2021. Active employment observations only."
  ) +
  theme_psid

ggsave("output/plot1_wage_lifecycle.png", p1, width = 11, height = 6, dpi = 150)

# =============================================================================
# PLOT 2 — Employment rate lifecycle by income quintile (truncated at 65)
# =============================================================================
plot2_data <- panel %>%
  filter(!is.na(wage_quintile), !is.na(age), !is.na(employed),
         age >= 20, age <= 65) %>%
  mutate(age_bin = floor(age / 2) * 2) %>%
  group_by(wage_quintile, age_bin) %>%
  summarise(pct_employed = mean(employed, na.rm = TRUE) * 100,
            n = n(), .groups = "drop") %>%
  filter(n >= 30)

p2 <- ggplot(plot2_data,
             aes(x = age_bin, y = pct_employed,
                 color = factor(wage_quintile),
                 group = factor(wage_quintile))) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  scale_color_manual(values = quintile_palette, labels = quintile_labels,
                     name = "Income quintile") +
  scale_y_continuous(labels = function(x) paste0(x, "%"), 
                   limits = c(50, 100)) +  scale_x_continuous(breaks = seq(20, 65, 5)) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "gray50") +
  annotate("text", x = 50.5, y = 95,
           label = "Later life (50+)", hjust = 0, size = 3.2, color = "gray40") +
  labs(
    title    = "Employment rate over the lifecycle by income quintile",
    subtitle = "Share employed by 2-year age bins",
    x        = "Age",
    y        = "% Employed",
    caption  = "Source: PSID 1979–2021."
  ) +
  theme_psid

ggsave("output/plot2_employment_lifecycle.png", p2, width = 11, height = 6, dpi = 150)


# =============================================================================
# Save analysis-ready dataset
# =============================================================================

# Individual-level CV of employment (to merge back into panel)
cv_individual <- panel %>%
  filter(!is.na(employed), age >= 20, age <= 65) %>%
  group_by(person_id) %>%
  summarise(
    mean_emp = mean(employed, na.rm = TRUE),
    sd_emp   = sd(employed, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  filter(!is.na(sd_emp), mean_emp > 0) %>%
  mutate(cv_emp = sd_emp / mean_emp) %>%
  select(person_id, cv_emp)

panel <- panel %>%
  left_join(cv_individual, by = "person_id")

panel_analysis <- panel %>%
  select(person_id, year, age, sex, employed, wage_real,
         wage_hist_mean, wage_hist_n, wage_quintile,
         cv_emp, k6_distress, life_satisfaction, health,
         empl_status, cpi)

write.csv(panel_analysis, "data/psid_analysis_ready.csv", row.names = FALSE)

message("End code Analysis")
