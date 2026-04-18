# =============================================================================
# Master Script
# =============================================================================
# Runs all project scripts in order:
#   1. clean_data.R  — builds the individual-level long panel from raw PSID
#   2. analysis.R    — constructs variables, descriptive table, and plots
#   3. estimation.R  — performs regression analysis
# =============================================================================

# Set working directory to project root (adjust path if needed)
# setwd("/path/to/your/project")

# --- 1. Clean data ------------------------------------------------------------
source("code/1_clean_data.R")

# --- 2. Analysis --------------------------------------------------------------
source("code/2_analysis.R")

# --- 3. Estimation ------------------------------------------------------------
source("code/3_estimation.R")