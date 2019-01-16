Evaluate <- function(gbm.model, test.data.split) {
  
  test.data.split$pred <- suppressWarnings(predict(gbm.model, test.data.split))
  # Investigate test error
  error.tbl <- test.data.split %>%
    # add_column(pred = predictions.tbl %>% as.tibble() %>% pull(pred)) %>%
    rename(actual = target_train) %>%
    mutate(
      error = actual - pred,
      error.pct = error / actual
    ) %>%
    mutate(error.pct = ifelse(is.infinite(error.pct), NA, error.pct)) %>%
    summarise(
      me = mean(error),
      rmse = mean(error^2)^0.5,
      mae = mean(abs(error)),
      mape = mean(abs(error.pct), na.rm = TRUE),
      mpe = mean(error.pct, na.rm = TRUE)
    )
  
  return(error.tbl)
}