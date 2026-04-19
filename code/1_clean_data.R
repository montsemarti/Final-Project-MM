# =============================================================================
# PSID Individual-Level Panel Construction
# =============================================================================
 
# --- 0. Packages --------------------------------------------------------------
library(readxl)       
library(dplyr)        
library(tidyr)        
library(haven)        
library(stringr)      
 
# --- 1. Load data -------------------------------------------------------------
raw <- read_excel("psid/psid.xlsx", sheet = "Data")
 
# --- 2. Variable map ----------------------------------------------------------
# Each entry: var_code -> list(year, concept)
# Concepts: interview_num, seq_num, relation, empl_status,
#           age, sex, wage, health, psych_problem, k6_distress,
#           life_satisfaction, ethnic, educ

 
var_map <- tribble(
  ~var,        ~year, ~concept,
  # --- Permanent IDs (no year dimension) ---
  "ER30001",   NA,    "id_68",          # 1968 family interview number
  "ER30002",   NA,    "id_person",      # person number within 1968 family
  "ER32000",   NA,    "sex_individual", # sex of individual
  "ER32006",   NA,    "sample_type",    # whether sample or non-sample member
 
  # --- 1968 ---
  "ER30003",   1968,  "relation",
  "V117",      1968,  "age",
  "V119",      1968,  "sex",
  "V337",      1968,  "wage",
 
  # --- 1969 ---
  "ER30020",   1969,  "interview_num",
  "ER30021",   1969,  "seq_num",
  "ER30022",   1969,  "relation",
  "ER30030",   1969,  "disabled",
  "V1239",     1969,  "age",
  "V1240",     1969,  "sex",
  "V1567",     1969,  "wage",
 
  # --- 1970 ---
  "ER30043",   1970,  "interview_num",
  "ER30044",   1970,  "seq_num",
  "ER30045",   1970,  "relation",
  "ER30054",   1970,  "disabled",
  "V1942",     1970,  "age",
  "V1943",     1970,  "sex",
  "V2279",     1970,  "wage",
 
  # --- 1971 ---
  "ER30067",   1971,  "interview_num",
  "ER30068",   1971,  "seq_num",
  "ER30069",   1971,  "relation",
  "ER30078",   1971,  "disabled",
  "V2542",     1971,  "age",
  "V2543",     1971,  "sex",
  "V2906",     1971,  "wage",
 
  # --- 1972 ---
  "ER30091",   1972,  "interview_num",
  "ER30092",   1972,  "seq_num",
  "ER30093",   1972,  "relation",
  "ER30103",   1972,  "disabled",
  "V3095",     1972,  "age",
  "V3096",     1972,  "sex",
  "V3275",     1972,  "wage",
 
  # --- 1973 ---
  "ER30117",   1973,  "interview_num",
  "ER30118",   1973,  "seq_num",
  "ER30119",   1973,  "relation",
  "V3508",     1973,  "age",
  "V3509",     1973,  "sex",
  "V3695",     1973,  "wage",
 
  # --- 1974 ---
  "ER30138",   1974,  "interview_num",
  "ER30139",   1974,  "seq_num",
  "ER30140",   1974,  "relation",
  "V3921",     1974,  "age",
  "V3922",     1974,  "sex",
  "V4174",     1974,  "wage",
 
  # --- 1975 ---
  "ER30160",   1975,  "interview_num",
  "ER30161",   1975,  "seq_num",
  "ER30162",   1975,  "relation",
  "V4436",     1975,  "age",
  "V4437",     1975,  "sex",
  "V5050",     1975,  "wage",
 
  # --- 1976 ---
  "ER30188",   1976,  "interview_num",
  "ER30189",   1976,  "seq_num",
  "ER30190",   1976,  "relation",
  "V5350",     1976,  "age",
  "V5351",     1976,  "sex",
  "V5631",     1976,  "wage",
 
  # --- 1977 ---
  "ER30217",   1977,  "interview_num",
  "ER30218",   1977,  "seq_num",
  "ER30219",   1977,  "relation",
  "V5850",     1977,  "age",
  "V5851",     1977,  "sex",
  "V6178",     1977,  "wage",
 
  # --- 1978 ---
  "ER30246",   1978,  "interview_num",
  "ER30247",   1978,  "seq_num",
  "ER30248",   1978,  "relation",
  "V6462",     1978,  "age",
  "V6463",     1978,  "sex",
  "V6771",     1978,  "wage",
 
  # --- 1979 ---
  "ER30283",   1979,  "interview_num",
  "ER30284",   1979,  "seq_num",
  "ER30285",   1979,  "relation",
  "ER30293",   1979,  "empl_status",
  "V7067",     1979,  "age",
  "V7068",     1979,  "sex",
  "V7417",     1979,  "wage",
 
  # --- 1980 ---
  "ER30313",   1980,  "interview_num",
  "ER30314",   1980,  "seq_num",
  "ER30315",   1980,  "relation",
  "ER30323",   1980,  "empl_status",
  "V7658",     1980,  "age",
  "V7659",     1980,  "sex",
  "V8069",     1980,  "wage",
 
  # --- 1981 ---
  "ER30343",   1981,  "interview_num",
  "ER30344",   1981,  "seq_num",
  "ER30345",   1981,  "relation",
  "ER30353",   1981,  "empl_status",
  "V8352",     1981,  "age",
  "V8353",     1981,  "sex",
  "V8693",     1981,  "wage",
 
  # --- 1982 ---
  "ER30373",   1982,  "interview_num",
  "ER30374",   1982,  "seq_num",
  "ER30375",   1982,  "relation",
  "ER30382",   1982,  "empl_status",
  "V8961",     1982,  "age",
  "V8962",     1982,  "sex",
  "V9379",     1982,  "wage",
 
  # --- 1983 ---
  "ER30399",   1983,  "interview_num",
  "ER30400",   1983,  "seq_num",
  "ER30401",   1983,  "relation",
  "ER30411",   1983,  "empl_status",
  "V10419",    1983,  "age",
  "V10420",    1983,  "sex",
  "V11026",    1983,  "wage",
 
  # --- 1984 ---
  "ER30429",   1984,  "interview_num",
  "ER30430",   1984,  "seq_num",
  "ER30431",   1984,  "relation",
  "ER30441",   1984,  "empl_status",
  "V11606",    1984,  "age",
  "V11607",    1984,  "sex",
  "V12377",    1984,  "wage",
 
  # --- 1985 ---
  "ER30463",   1985,  "interview_num",
  "ER30464",   1985,  "seq_num",
  "ER30465",   1985,  "relation",
  "ER30474",   1985,  "empl_status",
  "V13011",    1985,  "age",
  "V13012",    1985,  "sex",
  "V13629",    1985,  "wage",
 
  # --- 1986 ---
  "ER30498",   1986,  "interview_num",
  "ER30499",   1986,  "seq_num",
  "ER30500",   1986,  "relation",
  "ER30509",   1986,  "empl_status",
  "V14114",    1986,  "age",
  "V14115",    1986,  "sex",
  "V14676",    1986,  "wage",
 
  # --- 1987 ---
  "ER30535",   1987,  "interview_num",
  "ER30536",   1987,  "seq_num",
  "ER30537",   1987,  "relation",
  "ER30545",   1987,  "empl_status",
  "V15130",    1987,  "age",
  "V15131",    1987,  "sex",
  "V16150",    1987,  "wage",
 
  # --- 1988 ---
  "ER30570",   1988,  "interview_num",
  "ER30571",   1988,  "seq_num",
  "ER30572",   1988,  "relation",
  "ER30580",   1988,  "empl_status",
  "V16631",    1988,  "age",
  "V16632",    1988,  "sex",
  "V17536",    1988,  "wage",
 
  # --- 1989 ---
  "ER30606",   1989,  "interview_num",
  "ER30607",   1989,  "seq_num",
  "ER30608",   1989,  "relation",
  "ER30616",   1989,  "empl_status",
  "V18049",    1989,  "age",
  "V18050",    1989,  "sex",
  "V18887",    1989,  "wage",
 
  # --- 1990 ---
  "ER30642",   1990,  "interview_num",
  "ER30643",   1990,  "seq_num",
  "ER30644",   1990,  "relation",
  "ER30652",   1990,  "empl_status",
  "V19349",    1990,  "age",
  "V19350",    1990,  "sex",
  "V20175",    1990,  "wage",
 
  # --- 1991 ---
  "ER30689",   1991,  "interview_num",
  "ER30690",   1991,  "seq_num",
  "ER30691",   1991,  "relation",
  "ER30699",   1991,  "empl_status",
  "V20651",    1991,  "age",
  "V20652",    1991,  "sex",
  "V21481",    1991,  "wage",
 
  # --- 1992 ---
  "ER30733",   1992,  "interview_num",
  "ER30734",   1992,  "seq_num",
  "ER30735",   1992,  "relation",
  "ER30743",   1992,  "empl_status",
  "V22405",    1992,  "age",
  "V22406",    1992,  "sex",
  "V23276",    1992,  "wage",
 
  # --- 1993 ---
  "ER30806",   1993,  "interview_num",
  "ER30807",   1993,  "seq_num",
  "ER30808",   1993,  "relation",
  "ER30816",   1993,  "empl_status",
  "ER30820",   1993,  "age",
  "ER30821",   1993,  "sex",
  "V24116",    1993,  "wage",
 
  # --- 1994 ---
  "ER33101",   1994,  "interview_num",
  "ER33102",   1994,  "seq_num",
  "ER33103",   1994,  "relation",
  "ER33115",   1994,  "empl_status",
  "ER33104",   1994,  "age",
  "ER33107",   1994,  "sex",
  "ER33128",   1994,  "health",
  "V25362",    1994,  "wage",
 
  # --- 1995 ---
  "ER33201",   1995,  "interview_num",
  "ER33202",   1995,  "seq_num",
  "ER33203",   1995,  "relation",
  "ER33215",   1995,  "empl_status",
  "ER33204",   1995,  "age",
  "ER33207",   1995,  "sex",
  "ER33284",   1995,  "health",
  "V26391",    1995,  "wage",
 
  # --- 1996 ---
  "ER33301",   1996,  "interview_num",
  "ER33302",   1996,  "seq_num",
  "ER33303",   1996,  "relation",
  "ER33315",   1996,  "empl_status",
  "ER33304",   1996,  "age",
  "ER33307",   1996,  "sex",
  "ER33326",   1996,  "health",
  "V27377",    1996,  "wage",
 
  # --- 1997 ---
  "ER33401",   1997,  "interview_num",
  "ER33402",   1997,  "seq_num",
  "ER33403",   1997,  "relation",
  "ER33413",   1997,  "empl_status",
  "ER33404",   1997,  "age",
  "ER33407",   1997,  "sex",
  "ER16463",   1997,  "health",
  "ER16516",   1997,  "wage",
 
  # --- 1999 ---
  "ER33501",   1999,  "interview_num",
  "ER33502",   1999,  "seq_num",
  "ER33503",   1999,  "relation",
  "ER33513",   1999,  "empl_status",
  "ER33504",   1999,  "age",
  "ER33507",   1999,  "sex",
  "ER18456",   1999,  "health",
  "ER18565",   1999,  "psych_problem",
  "ER18722",   1999,  "k6_distress",
  "ER20443",   1999,  "wage",
 
  # --- 2001 ---
  "ER33601",   2001,  "interview_num",
  "ER33602",   2001,  "seq_num",
  "ER33603",   2001,  "relation",
  "ER33613",   2001,  "empl_status",
  "ER33604",   2001,  "age",
  "ER33607",   2001,  "sex",
  "ER19989",   2001,  "health",
  "ER20059",   2001,  "psych_problem",
  "ER19833A",  2001,  "k6_distress",
  "ER20451",   2001,  "wage",
 
  # --- 2003 ---
  "ER33701",   2003,  "interview_num",
  "ER33702",   2003,  "seq_num",
  "ER33703",   2003,  "relation",
  "ER33713",   2003,  "empl_status",
  "ER33704",   2003,  "age",
  "ER33707",   2003,  "sex",
  "ER21369",   2003,  "health",
  "ER21445",   2003,  "psych_problem",
  "ER21657",   2003,  "k6_distress",
  "ER22631",   2003,  "wage",
 
  # --- 2005 ---
  "ER33801",   2005,  "interview_num",
  "ER33802",   2005,  "seq_num",
  "ER33803",   2005,  "relation",
  "ER33813",   2005,  "empl_status",
  "ER33804",   2005,  "age",
  "ER33807",   2005,  "sex",
  "ER25000",   2005,  "health",
  "ER25104",   2005,  "psych_problem",
  "ER25016",   2005,  "k6_distress",
  "ER26263",   2005,  "wage",
 
  # --- 2007 ---
  "ER33901",   2007,  "interview_num",
  "ER33902",   2007,  "seq_num",
  "ER33903",   2007,  "relation",
  "ER33913",   2007,  "empl_status",
  "ER33904",   2007,  "age",
  "ER33907",   2007,  "sex",
  "ER42024",   2007,  "life_satisfaction",
  "ER44175",   2007,  "health",
  "ER44229",   2007,  "psych_problem",
  "ER46375",   2007,  "k6_distress",
  "ER46547",   2007,  "ethnic",
  "ER46901",   2007,  "wage",
 
  # --- 2009 ---
  "ER34001",   2009,  "interview_num",
  "ER34002",   2009,  "seq_num",
  "ER34003",   2009,  "relation",
  "ER34016",   2009,  "empl_status",
  "ER47317",   2009,  "age",
  "ER47318",   2009,  "sex",
  "ER47324",   2009,  "life_satisfaction",
  "ER49494",   2009,  "health",
  "ER49562",   2009,  "psych_problem",
  "ER51736",   2009,  "k6_distress",
  "ER51908",   2009,  "ethnic",
  "ER52309",   2009,  "wage",
 
  # --- 2011 ---
  "ER34101",   2011,  "interview_num",
  "ER34102",   2011,  "seq_num",
  "ER34103",   2011,  "relation",
  "ER34116",   2011,  "empl_status",
  "ER53017",   2011,  "age",
  "ER53018",   2011,  "sex",
  "ER53024",   2011,  "life_satisfaction",
  "ER55244",   2011,  "health",
  "ER55311",   2011,  "psych_problem",
  "ER57482",   2011,  "k6_distress",
  "ER57663",   2011,  "ethnic",
  "ER58118",   2011,  "wage",
 
  # --- 2013 ---
  "ER34201",   2013,  "interview_num",
  "ER34202",   2013,  "seq_num",
  "ER34203",   2013,  "relation",
  "ER34216",   2013,  "empl_status",
  "ER34219",   2013,  "educ",
  "ER60017",   2013,  "age",
  "ER60018",   2013,  "sex",
  "ER60025",   2013,  "life_satisfaction",
  "ER62366",   2013,  "health",
  "ER62433",   2013,  "psych_problem",
  "ER64604",   2013,  "k6_distress",
  "ER64815",   2013,  "ethnic",
  "ER65315",   2013,  "wage",
 
  # --- 2015 ---
  "ER34301",   2015,  "interview_num",
  "ER34302",   2015,  "seq_num",
  "ER34303",   2015,  "relation",
  "ER34317",   2015,  "empl_status",
  "ER66017",   2015,  "age",
  "ER66018",   2015,  "sex",
  "ER66025",   2015,  "life_satisfaction",
  "ER68420",   2015,  "health",
  "ER68487",   2015,  "psych_problem",
  "ER70680",   2015,  "k6_distress",
  "ER70887",   2015,  "ethnic",
  "ER71392",   2015,  "wage",
 
  # --- 2017 ---
  "ER34501",   2017,  "interview_num",
  "ER34502",   2017,  "seq_num",
  "ER34503",   2017,  "relation",
  "ER34516",   2017,  "empl_status",
  "ER72017",   2017,  "age",
  "ER72018",   2017,  "sex",
  "ER72025",   2017,  "life_satisfaction",
  "ER74428",   2017,  "health",
  "ER74495",   2017,  "psych_problem",
  "ER76688",   2017,  "k6_distress",
  "ER76902",   2017,  "ethnic",
  "ER77414",   2017,  "wage",
 
  # --- 2019 ---
  "ER34701",   2019,  "interview_num",
  "ER34702",   2019,  "seq_num",
  "ER34703",   2019,  "relation",
  "ER34716",   2019,  "empl_status",
  "ER78017",   2019,  "age",
  "ER78018",   2019,  "sex",
  "ER78026",   2019,  "life_satisfaction",
  "ER80550",   2019,  "health",
  "ER80643",   2019,  "psych_problem",
  "ER80952",   2019,  "k6_distress",
  "ER81149",   2019,  "ethnic",
  "ER81741",   2019,  "wage",
 
  # --- 2021 ---
  "ER34901",   2021,  "interview_num",
  "ER34902",   2021,  "seq_num",
  "ER34903",   2021,  "relation",
  "ER34916",   2021,  "empl_status",
  "ER82018",   2021,  "age",
  "ER82019",   2021,  "sex",
  "ER82027",   2021,  "life_satisfaction",
  "ER84520",   2021,  "health",
  "ER84615",   2021,  "psych_problem",
  "ER84928",   2021,  "k6_distress",
  "ER85126",   2021,  "ethnic",
  "ER85595",   2021,  "wage",
 
  # --- 2023 ---
  "ER35101",   2023,  "interview_num",
  "ER35102",   2023,  "seq_num",
  "ER35103",   2023,  "relation",
  "ER35116",   2023,  "empl_status"
)
 
# --- 3. Extract permanent (time-invariant) variables -------------------------
perm_vars <- var_map %>% filter(is.na(year)) %>% pull(var)
perm_vars  <- intersect(perm_vars, colnames(raw))   
 
permanent <- raw %>%
  select(all_of(perm_vars)) %>%
  rename(
    id_68         = ER30001,
    id_person     = ER30002,
    sex_individual = ER32000,
    sample_type   = ER32006
  ) %>%
  mutate(
    person_id = id_68 * 1000 + id_person   # unique individual key
  )
 
# --- 4. Build one data frame per year --------------------
years_in_map <- var_map %>% filter(!is.na(year)) %>% pull(year) %>% unique() %>% sort()
 
build_year <- function(yr) {
  vars_yr <- var_map %>%
    filter(year == yr) %>%
    select(var, concept)
 
  # Keep only columns present in raw
  vars_yr <- vars_yr %>% filter(var %in% colnames(raw))
 
  if (nrow(vars_yr) == 0) return(NULL)
 
  # Select & rename
  sel  <- vars_yr$var
  nms  <- vars_yr$concept
 
  slice_df <- raw %>%
    select(ER30001, ER30002, all_of(sel)) %>%
    rename_with(~ nms, all_of(sel)) %>%
    mutate(
      person_id = ER30001 * 1000 + ER30002,
      year      = yr
    ) %>%
    select(-ER30001, -ER30002)
 
  # Fill missing concepts with NA
  all_concepts <- c("interview_num", "seq_num", "relation", "empl_status",
                    "age", "sex", "wage", "health", "psych_problem",
                    "k6_distress", "life_satisfaction", "ethnic", "educ", "disabled")
  for (col in all_concepts) {
    if (!col %in% colnames(slice_df)) slice_df[[col]] <- NA_real_
  }
 
  slice_df
}
 
panel_list <- lapply(years_in_map, build_year)
panel_long <- bind_rows(panel_list)
 
# Merge permanent variables
panel_long <- panel_long %>%
  left_join(permanent %>% select(person_id, sex_individual, sample_type),
            by = "person_id")
 
 
# --- 5. Clean missing value codes -------------------------------------------
# PSID uses survey-specific missing codes; convert all to NA.
#   relation     : 0 = inap/not in FU -> NA
#   empl_status  : 0 = inap, 9 = NA/DK -> NA
#   age          : 0 = inap -> NA  (ages run 1-99+)
#   sex          : 0, 9 -> NA  (1=Male, 2=Female)
#   sex_individual: 0, 9 -> NA
#   wage         : 9999, 9998, 99.99 -> NA; 0 = did not work (keep as 0)
#   health       : 0 = inap, 8 = DK, 9 = NA -> NA  (1-5 scale)
#   psych_problem: 0 = inap, 8 = DK, 9 = NA -> NA  (1=Yes, 5=No)
#   k6_distress  : 99 = NA/inap -> NA  (0-24 scale)
#   life_sat     : 0 = inap, 8 = DK, 9 = NA -> NA  (1-5 scale)
#   ethnic       : 9 = NA -> NA
#   educ         : 98, 99 -> NA
#   disabled     : 0, 9 -> NA
 
panel_clean <- panel_long %>%
  mutate(
    # Relation to head/reference person
    relation       = if_else(relation %in% c(0), NA_real_, relation),
 
    # Employment status
    empl_status    = if_else(empl_status %in% c(0, 9), NA_real_, empl_status),
 
    # Age
    age = if_else(age %in% c(0, 999), NA_real_, age), 
    
    # Sex 
    sex            = if_else(sex %in% c(0, 9), NA_real_, sex),
 
    # Sex individual 
    sex_individual = if_else(sex_individual %in% c(0, 9), NA_real_, sex_individual),
 
    # Wage: 9999, 9998, 99.99 -> NA
    wage           = case_when(
      wage >= 9998        ~ NA_real_,
      wage == 99.99       ~ NA_real_,
      TRUE                ~ wage
    ),
 
    # Health status (1=Excellent ... 5=Poor)
    health         = if_else(health %in% c(0, 8, 9), NA_real_, health),
 
    # Psych problem (1=Yes, 5=No)
    psych_problem  = if_else(psych_problem %in% c(0, 8, 9), NA_real_, psych_problem),
 
    # K6 distress scale (0-24)
    k6_distress    = if_else(k6_distress == 99, NA_real_, k6_distress),
 
    # Life satisfaction (1=Completely satisfied ... 5=Not at all)
    life_satisfaction = if_else(life_satisfaction %in% c(0, 8, 9), NA_real_, life_satisfaction),
 
    # Ethnicity
    ethnic         = if_else(ethnic %in% c(9), NA_real_, ethnic),
 
    # Education (highest grade completed)
    educ           = if_else(educ %in% c(98, 99), NA_real_, educ),
 
    # Disabled
    disabled       = if_else(disabled %in% c(0, 9), NA_real_, disabled)
  )
 
# --- 6. Resolve sex variable -----------------------------------------
panel_clean <- panel_clean %>%
  mutate(
    sex_final = coalesce(sex_individual, sex)
  ) %>%
  select(-sex, -sex_individual)
 
# --- 7. Sort and column order -----------------------------------------
panel_final <- panel_clean %>%
  arrange(person_id, year) %>%
  select(
    person_id,
    year,
    interview_num,
    seq_num,
    relation,
    sample_type,
    age,
    sex_final,
    empl_status,
    wage,
    health,
    psych_problem,
    k6_distress,
    life_satisfaction,
    ethnic,
    educ,
    disabled
  ) %>%
  rename(sex = sex_final)

 
# --- 8. Export ---------------------------------------------------------------
 
# Stata .dta
# write_dta(panel_final, "data/psid_panel_long.dta")
 
# CSV fallback
write.csv(panel_final, "data/psid_panel_long.csv", row.names = FALSE)

message("End code Cleaning")
 
