# Applied Economics Analysis
### Final Project

---

## Overview

This project uses the **Panel Study of Income Dynamics (PSID)** to examine whether a lifetime of high earnings and stable employment is associated with better psychological well-being and life satisfaction in later life (age 50+). The analysis spans 1968–2021 and follows individuals from early career to old age.

---

## Project Structure

```
project/
│
├── psid/
|   ├── psid.xlsx                   # Not included
|   ├── psid_labels.txt             # Not included
|   └── psid_codebook.pdf           # Not included
|
├── data/
│   ├── psid_panel_long.csv          # Not included: Clean individual-level long panel (output of 1_clean_data.R)
│   └── psid_analysis_ready.csv      # Not included:: Analysis-ready dataset with constructed variables (output of 2_analysis.R)
│
├── code/
│   ├── 0_main.R                     # Master script — runs all scripts in order
│   ├── 1_clean_data.R               # Builds long panel from raw PSID xlsx
│   ├── 2_analysis.R                 # Variable construction, descriptive tables, and plots
│   └── 3_estimation.R               # OLS regressions and results table
│
├── output/
│   ├── table1a_individual.tex       # Individual-level descriptive statistics (LaTeX)
│   ├── table1b_summary.tex          # Summary by income quintile: CV, K6, life satisfaction (LaTeX)
│   ├── table_regression.tex         # Preliminary OLS results (LaTeX)
│   ├── plot1_wage_lifecycle.png     # Real wage lifecycle by income quintile
│   └── plot2_employment_lifecycle.png # Employment rate lifecycle by income quintile
│
├── presentation.qmd                 # Quarto Beamer presentation
├── presentation.pdf                 # PDF Beamer presentation
├── renv.lock                        # Package versions for reproducibility
└── README.md
```

---

## Data

Raw data can be requested at [psidonline.isr.umich.edu](https://psidonline.isr.umich.edu) (you may be requested to create an account). The exact extract used in this project can be accessed by entering the following  email in the PSID Data Center under "Previous Carts": montserrat_marti@brown.edu (Job ID: 359956). Make sure to select Microsoft Spreadsheet as the download format.

---


**Input files** 
Rename files as follow:

| File | Description |
|---|---|
| `psid.xlsx` | Raw PSID extract (1968–2023) |
| `psid_labels.txt` | Variable labels from PSID Data Center |
| `psid_codebook.pdf` | Full variable codebook |



---

## How to Run

### 1. Install packages

```r
install.packages("renv")
renv::restore()
```

### 2. Place raw data files in the project root (create psid folder)

```
project/
└── psid/
    ├── psid.xlsx
    ├── psid_labels.txt
    └── psid_codebook.pdf
```

## 3. Create data folder

```
project/
└── data

```

### 4. Run the master script
Change directory. Then run:

```r
source("code/0_main.R")
```

This will sequentially run `1_clean_data.R`, `2_analysis.R`, and `3_estimation.R`, generating all outputs in the `output/` folder.

---

### Constructed variables

| Variable | Description |
|---|---|
| `wage_hist_mean` | Historical average real wage per individual (across all employed person-years) |
| `wage_quintile` | Income quintile based on historical average wage (Q1=lowest, Q5=highest) |
| `employed` | Binary employment indicator (1=working, 0=otherwise) |
| `cv_emp` | Coefficient of variation of employment status (age 20–65); lower = more stable |


