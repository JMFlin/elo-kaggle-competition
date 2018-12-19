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

train.data <- read_csv("data/train.csv", n_max = 20000)
historical <- read_csv("data/historical_transactions.csv", n_max = 20000)
merchants <- read_csv("data/merchants.csv", n_max = 20000)
new.merchant.transactions <- read_csv("data/new_merchant_transactions.csv", n_max = 20000)

head(train.data)
head(historical)
head(merchants)
head(new.merchant.transactions)
