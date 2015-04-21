library(dplyr)
library(ggplot2)
library(scales)

DATA_FILE <- "../data/2012-data.csv"

# Import data and clean it for malformed input
data <- read.csv(DATA_FILE, header=T, quote = "", na.strings = c("NA", "NULL"))
data <- na.omit(data)

# Reports per percinct
precincts <- data %>% group_by(pct) %>% summarize(num_stops=n())
ggplot(precincts, aes(x=pct,y=num_stops)) + 
  geom_bar(stat="identity") +
  xlab("Precinct") + 
  ylab("Number of Stops")

# Reports per day
time_data <- data %>% group_by(datestop) %>% summarize(num_stops=n())
# Replace ambiguous date strings with date objects
time_data$datestop <- seq(as.Date("2012/1/1"), as.Date("2012/12/31"), "days")
ggplot(time_data, aes(x=datestop,y=num_stops)) +
  scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels=date_format("%m/%Y")) +
  geom_bar(stat="identity") +
  xlab("Date of Stop") +
  ylab("Cumulative Frequency")

# Reports for each day of the week
time_data$day <- weekdays(time_data$datestop)
day_data <- time_data %>% group_by(day) %>% summarize(nums=sum(num_stops))
day_data$percent <- round(((day_data$nums / sum(day_data$nums)) * 100),2)
day_data$labels <- paste(day_data$day," ",day_data$percent,"%",sep="")
pie(day_data$nums, labels=day_data$labels, main="Stops for Each Day")







