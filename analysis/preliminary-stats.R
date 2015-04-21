library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)

DATA_FILE <- "../data/2012-data.csv"
LABELS_FILE <- "../data/labels.csv"

# Import labels so we can later replace them
labels <- read.csv(LABELS_FILE, header=T, quote="", na.strings = c("NA", "NULL"))
get_label <- function(lab,cod) {
  return(as.character(filter(labels,label==lab,code==cod)[1,]$expansion))
}

# Import data and clean it for malformed input
data <- read.csv(DATA_FILE, header=T, quote = "", na.strings = c("NA", "NULL"))
data <- na.omit(data)

# Reports per precinct
precincts <- data %>% group_by(pct) %>% summarize(num_stops=n())
ggplot(precincts, aes(x=pct,y=num_stops)) + 
  geom_bar(stat="identity") +
  xlab("Precinct") + 
  ylab("Number of Stops") +
  ggtitle("Number of Stops per precinct")

# Reports per day
time_data <- data %>% group_by(datestop) %>% summarize(num_stops=n())
# Replace ambiguous date strings with date objects
time_data$datestop <- seq(as.Date("2012/1/1"), as.Date("2012/12/31"), "days")
ggplot(time_data, aes(x=datestop,y=num_stops)) +
  scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels=date_format("%m/%Y")) +
  geom_bar(stat="identity") +
  xlab("Date") +
  ylab("Number of Stops") +
  ggtitle("Number of Stops per day")

# Reports for each day of the week
time_data$day <- weekdays(time_data$datestop)
day_data <- time_data %>% group_by(day) %>% summarize(nums=sum(num_stops))
day_data$percent <- round(((day_data$nums / sum(day_data$nums)) * 100),2)
day_data$labels <- paste(day_data$day," ",day_data$percent,"%",sep="")
pie(day_data$nums, labels=day_data$labels, main="Stops for Each Day")

# Arrests made, guns found, and overall numbers by race
race_data <- data %>% group_by(race) %>% summarize(arrests=sum(arstmade),
                                                   guns=sum(pistol+asltweap+riflshot+
                                                       knifcuti+machgun+othrweap),
                                                   total=n())

# Only graph for the 5 most occurring races
ordered_race_data <- race_data[order(-race_data$total),]
ordered_race_data <- ordered_race_data[1:5,]
# Replace abbreviations with full names
ordered_race_data$race <- gsub("A","asian",ordered_race_data$race)
ordered_race_data$race <- gsub("B","black",ordered_race_data$race)
ordered_race_data$race <- gsub("P","black hispanic",ordered_race_data$race)
ordered_race_data$race <- gsub("Q","white hispanic",ordered_race_data$race)
ordered_race_data$race <- gsub("W","white",ordered_race_data$race)

# Melt the data so it's easier for us to plot the different features
melted <- melt(ordered_race_data, "race") 
melted$type <- ''
melted[melted$variable == 'arrests',]$type <- "a"
melted[melted$variable == 'total',]$type <- "t"
melted[melted$variable == 'guns',]$type <- "g"
ggplot(melted, aes(x = type, y = value, fill = variable)) + 
        geom_bar(stat = 'identity') + facet_grid(~ race) +
        xlab("Race and Feature") +
        ylab("Number of Occurrences") +
        ggtitle("Arrests, Weapons, and Stops by Race")

# Report the percentages for each of these things
ordered_race_data$arrests = paste(round(((ordered_race_data$arrests) / (ordered_race_data$total)) * 100,2),"%",sep="")
ordered_race_data$guns = paste(round(((ordered_race_data$guns) / (ordered_race_data$total)) * 100,2),"%",sep="")
print(ordered_race_data)

# Look at the most common crimes
# First, remove all spaces from our data
data$detailcm <- gsub(" ", "", data$detailcm, fixed = TRUE)
crime_data <- data %>% group_by(detailcm) %>% summarize(incidences=n())
crime_data <- crime_data[order(-crime_data$incidences),]
top_crime_data <- crime_data[1:20,]
top_crime_data$label <- ''
for (i in 1:nrow(top_crime_data)) {
  top_crime_data[i,]$label <- get_label("detailcm",top_crime_data[i,]$detailcm)
}
print(top_crime_data)

# Number of stops by age
stops_by_age <- data %>% group_by(age) %>% summarize(count=n())
stops_by_age$age <- as.numeric(as.character(stops_by_age$age))
stops_by_age <- filter(stops_by_age,age<=100,age>=10)
stops_by_age$percent <- stops_by_age$count / (sum(stops_by_age$count))
ggplot() + 
  geom_point(data=stops_by_age, aes(x=age,y=count), shape = 1) + 
  geom_line(data=stops_by_age, aes(x=age,y=count,color="Age")) +
  xlab("Age (years)") +
  ylab("Number of Stops") +
  ggtitle("Number of Stops by Age")








