library(dplyr)

DATA_FILE <- "../data/2012-data.csv"

data <- read.csv(DATA_FILE, header=T, quote = "", na.strings = c("NA", "NULL"))
data <- na.omit(data)

gender_data <- data %>% group_by(sex) %>% summarize(count=n())