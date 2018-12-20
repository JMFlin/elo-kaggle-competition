setwd("C:/Users/janne.m.flinck/Desktop/elo-kaggle-competition")

if (!require("pacman")) install.packages("pacman") # get pcaman if not present and load it
pacman::p_load( # let pacman control packages
  "readr", 
  "ggplot2",
  "lubridate",
  "futile.logger",
  "caret",
  "tidyverse",
  "janitor"
)


train.data <- read_csv("data/train.csv", n_max = 100000, col_types = cols(
  first_active_month = col_character(),
  card_id = col_character(),
  feature_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  target = col_double()
)) %>%
  set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))



historical <- read_csv("data/historical_transactions.csv", n_max = 100000, col_types = cols(
  authorized_flag = col_character(),
  card_id = col_character(),
  city_id = col_double(),
  category_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  installments = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  category_3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  merchant_category_id = col_double(),
  merchant_id = col_character(),
  month_lag = col_double(),
  purchase_amount = col_double(),
  purchase_date = col_datetime(format = ""),
  category_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  state_id = col_double(),
  subsector_id = col_double()
)) %>%
  purrr:set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))



merchants <- read_csv("data/merchants.csv", n_max = 100000, col_types = cols(
  merchant_id = col_character(),
  merchant_group_id = col_double(),
  merchant_category_id = col_double(),
  subsector_id = col_double(),
  numerical_1 = col_double(),
  numerical_2 = col_double(),
  category_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  most_recent_sales_range = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  most_recent_purchases_range = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  avg_sales_lag3 = col_double(),
  avg_purchases_lag3 = col_double(),
  active_months_lag3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  avg_sales_lag6 = col_double(),
  avg_purchases_lag6 = col_double(),
  active_months_lag6 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  avg_sales_lag12 = col_double(),
  avg_purchases_lag12 = col_double(),
  active_months_lag12 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  category_4 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  city_id = col_double(),
  state_id = col_double(),
  category_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE)
)) %>%
  purrr:set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))


new.merchant.transactions <- read_csv("data/new_merchant_transactions.csv", n_max = 100000, col_types = cols(
  authorized_flag = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  card_id = col_character(),
  city_id = col_double(),
  category_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  installments = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  category_3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  merchant_category_id = col_double(),
  merchant_id = col_character(),
  month_lag = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  purchase_amount = col_double(),
  purchase_date = col_datetime(format = ""),
  category_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  state_id = col_double(),
  subsector_id = col_double()
)) %>%
  purrr:set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))



joined.data <- inner_join(train.data, historical, by = "card_id") %>%
  inner_join(., merchants, by = "merchant_id") 
#%>%
#  inner_join(., new.merchant.transactions, by = c("card_id", "merchant_id"))
  

