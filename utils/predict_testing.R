PredictTest <- function(test.data, model) {
  test.data <- test.data %>%
    mutate(month = factor(month(ymd(first_active_month_test, truncated = 1))),
           year = factor(year(ymd(first_active_month_test, truncated = 1)))) %>%
    select(-card_id, -first_active_month_test)
  
  test.data <- test.data %>%
    rename(feature_1_train = feature_1_test,
           feature_2_train = feature_2_test,
           feature_3_train = feature_3_test)
  
  preds <- suppressWarnings(predict(model, test.data[, predictors]))
  return(preds)
}
