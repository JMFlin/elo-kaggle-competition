setwd("C:/Users/janne.m.flinck/Desktop/elo-kaggle-competition")

if (!require("pacman")) install.packages("pacman") # get pcaman if not present and load it
pacman::p_load( # let pacman control packages
  "readr", 
  "ggplot2",
  "lubridate",
  "futile.logger",
  "caret",
  "tidyverse",
  "janitor",
  "styler",
  "tidyquant",
  "corrplot",
  "gbm"
)


read.rows <- 500000000

file.sources <- list.files("utils",
                           pattern = "*.R$", full.names = TRUE,
                           ignore.case = TRUE
)

invisible(sapply(file.sources, source, .GlobalEnv))#usethis::use_tidy_style()

train.data <- read_csv("data/train.csv", n_max = read.rows, col_types = cols(
  first_active_month = col_character(),
  card_id = col_character(),
  feature_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  target = col_double()
)) %>%
  purrr::set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))


test.data <- read_csv("data/test.csv", n_max = read.rows, col_types = cols(
  first_active_month = col_character(),
  card_id = col_character(),
  feature_1 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_2 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE),
  feature_3 = col_factor(levels = NULL, ordered = FALSE, include_na = TRUE)
)) %>%
  purrr::set_names(~ str_to_lower(.) %>%
                     str_replace_all(" ", "_"))


historical <- read_csv("data/historical_transactions.csv", n_max = read.rows, col_types = cols(
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
  purrr::set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))



merchants <- read_csv("data/merchants.csv", n_max = read.rows, col_types = cols(
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
  purrr::set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_"))


new.merchant.transactions <- read_csv("data/new_merchant_transactions.csv", n_max = read.rows, col_types = cols(
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
  purrr::set_names(~ str_to_lower(.) %>%
              str_replace_all(" ", "_")) 

train.data <- bind_cols(train.data %>%
                          select(c(card_id)),
                        train.data %>%
                          select(-c(card_id)) %>%
                          purrr::set_names(paste(colnames(.), "train", sep = "_")))

test.data <- bind_cols(test.data %>%
                         select(c(card_id)),
                       test.data %>%
                         select(-c(card_id)) %>%
                         purrr::set_names(paste(colnames(.), "test", sep = "_")))


historical <- bind_cols(historical %>%
                          select(c(card_id, city_id, state_id, subsector_id, merchant_id, merchant_category_id)),
                        historical %>%
                          select(-c(card_id, city_id, state_id, subsector_id, merchant_id, merchant_category_id)) %>%
                          purrr::set_names(paste(colnames(.), "historical", sep = "_")))

merchants <- bind_cols(merchants %>%
                         select(c(city_id, state_id, subsector_id, merchant_id, merchant_category_id, merchant_category_id)),
                       merchants %>%
                         select(-c(city_id, state_id, subsector_id, merchant_id, merchant_category_id, merchant_category_id)) %>%
                         purrr::set_names(paste(colnames(.), "merchants", sep = "_")))

new.merchant.transactions <- bind_cols(new.merchant.transactions %>%
                                         select(c(card_id, city_id, state_id, subsector_id, merchant_id, merchant_category_id)),
                                       new.merchant.transactions %>%
                                         select(-c(card_id, city_id, state_id, subsector_id, merchant_id, merchant_category_id)) %>%
  purrr::set_names(paste(colnames(.), "new.merchant.transactions", sep = "_")))



# joined.data <- inner_join(train.data, historical, by = "card_id") %>%
#   inner_join(., new.merchant.transactions, by = c("card_id")) %>% #"city_id","state_id","subsector_id", , "merchant_id","merchant_category_id"
#   inner_join(., merchants, by = c("city_id","state_id","subsector_id","merchant_id","merchant_category_id"))

train.data <- train.data %>%
  mutate(month = factor(month(ymd(first_active_month_train, truncated = 1))),
         year = factor(year(ymd(first_active_month_train, truncated = 1))))

CreatePlots(train.data)

outliers <- train.data %>%
  filter(target_train < -30)



train.data <- train.data %>%
  select(-card_id, -first_active_month_train) %>%
  select(target_train, everything())

predictors <- c("feature_1_train", "feature_2_train", 
                "feature_3_train", "month", "year")

target <- "target_train"


train.index <- createDataPartition(as_vector(train.data[,target]), 
                                   p = .6, 
                                   list = FALSE, 
                                   times = 1)

train.data.split <- train.data[ train.index,]
test.data.split <- train.data[-train.index,]

gbmGrid <- expand.grid(interaction.depth = c(1, 5, 10, 20),
                       n.trees = (1:30)*10,
                       shrinkage = 0.1,
                       n.minobsinnode = 20)

ctrl <- trainControl(method = "cv",
                     number = 2,
                     verboseIter = FALSE,
                     allowParallel = TRUE
)

x <- train.data.split %>%
  select(predictors) %>%
  as.data.frame()

y <- train.data.split %>%
  select(target) %>%
  as.data.frame() %>%
  as_vector()

gbm.model <- train(x,
                   y,
                   method = "gbm",
                   trControl = ctrl,
                   tuneGrid = gbmGrid,
                   metric = "RMSE"
)

lm.model <- train(x,
                   y,
                   method = "lm",
                   metric = "RMSE"
                   )

Evaluate(gbm.model, train.data.split)
Evaluate(lm.model, train.data.split)


# don't run
PredictTest(test.data, lm.model)
