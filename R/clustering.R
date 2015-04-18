require(dplyr)
#Read in data
data <- read.csv("../data/2012.csv", header=T)

#Preliminary data analysis
pct <- data$pct
#Seems to be 123 precincts
summary(pct)
#Some have a lot more than others
hist(pct, breaks=(1:123))
#Lets see which ones are unique and how many
pcts_with_data <- unique(pct)
sort(pcts_with_data)
length(pcts_with_data) 
# Seems correct http://www.nyc.gov/html/nypd/html/home/precincts.shtml

#extract x and y coordinates
x <- data$xcoord
y <- data$ycoord
####x[is.na(x)] <- 0
####y[is.na(y)] <- 0
geo_data <- data.frame(x=x, y=y)
geo_data_no_na <- na.omit(geo_data)

#K-means
num_clusters <- length(pcts_with_data)

#R k-means
ptm <- proc.time()
model <- kmeans(geo_data_no_na, num_clusters)
proc.time() - ptm

#Add cluster to data frame
geo_data_no_na$cluster <- model$cluster
#Add clusters to main data frame
merge(geo_data, geo_data_no_na, b)
#Get cluster centers
centers <- model$centers

#Lets see how large each cluster is

#Zach k-means
#geo_data[sample(dim(geo_data)[1], num_clusters, replace=F),]

ggplot(geo_data, aes(x=x, y=y)) +
  geom_point()