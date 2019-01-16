CreatePlots <- function(train.data) {
  
  pdf("figs/plots.pdf")
  
  print(train.data %>% 
    ggplot(aes(target_train)) +
    geom_histogram(bins = 100, fill = "steelblue", col = "gray") +
    theme_tq())
  
  print(train.data %>% 
    select(-first_active_month_train, -card_id) %>%
    gather(key = "feature", value = "value", -target_train) %>%
    #gather(variable, value, -target_train) %>%
    mutate(value = factor(value)) %>% 
    ggplot(., aes(x = value, y = target_train)) +
    ylab("") +
    xlab("") +
    ggtitle("") +
    stat_boxplot(geom = "errorbar") +
    geom_boxplot(aes(fill = feature)) +
    facet_wrap(. ~ feature, ncol = 3, scales = "free") +
    theme_tq() +
    theme(legend.position = "none"))
  
  
  print(train.data %>% 
    select(-first_active_month_train, -card_id, -target_train) %>% 
    gather(key = "feature", value = "value") %>% 
    mutate(value = factor(value)) %>% 
    ggplot(aes(value)) +
    geom_bar(aes(y = ..prop.., group = 1), fill = "steelblue", col = "gray") + #groupwise proportion
    facet_wrap(. ~ feature, scales = "free") +
    ylab("") +
    xlab("") +
    ggtitle("") +
    theme_tq() +
    theme(legend.position = "none"))
  
  print(train.data %>% 
    select(first_active_month_train, target_train) %>% 
    mutate(first_active_month_train = ymd(first_active_month_train, truncated = 1)) %>% 
    group_by(first_active_month_train) %>% 
    summarise(sum_target = sum(target_train), mean_target = mean(target_train)) %>% 
    ungroup() %>% 
    gather(key = "feature", value = "value", -first_active_month_train) %>% 
    ggplot(aes(x = first_active_month_train, y = value, colour = feature)) +
    geom_smooth(method = 'loess') +
    facet_wrap(~ feature, ncol = 1, scales = "free") + 
    ylab("") +
    xlab("") +
    ggtitle("") +
    theme_tq() +
    theme(legend.position = "none"))
  
  
  print(train.data %>% 
    select(first_active_month_train, card_id) %>% 
    mutate(first_active_month_train = ymd(first_active_month_train, truncated = 1)) %>% 
    group_by(first_active_month_train) %>% 
    summarise(n_distinct_card_id = n_distinct(card_id)) %>% 
    ungroup() %>% 
    gather(key = "feature", value = "value", -first_active_month_train) %>% 
    ggplot(aes(x = first_active_month_train, y = value, colour = feature)) +
    geom_smooth(method = 'loess') +
    facet_wrap(~ feature, ncol = 1, scales = "free") + 
    ylab("") +
    xlab("") +
    ggtitle("") +
    theme_tq() +
    theme(legend.position = "none"))
  
  
  print(train.data %>% 
    select(-card_id, -first_active_month_train) %>%
    mutate_if(is.factor, ~ as.character(.) %>% as.numeric()) %>% 
    cor(method = "spearman") %>%
    corrplot(type = "lower", method = "number", tl.col = "black", diag = FALSE, tl.cex = 0.9, number.cex = 0.9))
  
  dev.off()
  #ggsave("figs/plots.pdf", device = "pdf", width = 20, height = 20, units = "cm", limitsize = FALSE)
}
