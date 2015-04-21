require(dplyr)

######################
# Preliminary data analysis
######################

#Read in data
data <- read.csv("../data/2012.csv", header=T)

pct <- data$pct
summary(pct)
#pct ranges from 1:123, but does not include full range
hist(pct, breaks=(1:123))
#Lets see which ones are unique and how many
pcts_with_data <- unique(pct)
sort(pcts_with_data)
length(pcts_with_data) 
# Seems correct: http://www.nyc.gov/html/nypd/html/home/precincts.shtml

#extract x and y coordinates and place in data frame
geo_data <- data.frame(x=data$x, y=data$y)
#Omit data without geo_data
geo_data_no_na <- na.omit(geo_data)

###################################
# K-means
###################################

#Set the number of clusters equal to the number of police precints
num_clusters <- length(pcts_with_data)

####################
# R k-means
####################
ptm <- proc.time()
model <- kmeans(geo_data_no_na, num_clusters)
proc.time() - ptm

#Add cluster to data frame
geo_data_no_na$cluster <- model$cluster
#Get cluster centers
centers <- model$centers

######################
# Homemade k-means
#####################

#Helper function to find euclidean distance between two points
dist <- function(row, point) {
  x1 <- point[1]
  y1 <- point[2]
  x2 <- row[1]
  y2 <- row[2]
  
  sum_of_squared_diff <- (x2-x1)^2 + (y2-y1)^2
  return(sqrt(sum_of_squared_diff))
}

#Helper function to get min distance between point and centers
best_centers <- function(row, centers) {
  return(which.min(apply(centers, 1, dist, point=row)))
}

#Helper function to get distance between old centers and new centers
dist_between_centers <- function(old_centers, new_centers) {
  temp <- data.frame(x1=old_centers$x, y1<-old_centers$y, x2=new_centers$x, y2=new_centers$y)
  dist <- apply(temp, 1, function(row) sqrt((row[1]-row[3])^2 + (row[2]-row[4])^2))
  return(sum(dist))
}

# k means alg takes data, number of clusters k, and threshold parameter tau
# Make sure that data has no NA values
k_means <- function(data, k, tau) {
  #m is a vector where the index represents the cluster of the ith data point
  data_size <- dim(data)[1]
  m <- c()
  #Sample k random centers where k = num_clusters defined above
  old_centers <- data[sample(data_size, k, replace=F),]
  
  #make sure the centers are unique
  while(sum(duplicated(old_centers))!= 0) {
    old_centers <- data[sample(data_size, k, replace=F),]
  }
  
  new_centers <- old_centers
  repeat {
    #assign each data point to closeset center with smallest euclidean distance
    m <- apply(data, 1, best_centers, centers=new_centers) 
    #recompute each center as the average of all points assigned to it    
    data_with_cluster <- data.frame(data, cluster=m)
    
    temp <- data_with_cluster %>%
      group_by(cluster) %>%
      summarize(new_x=sum(x)/n(), new_y=sum(y)/n())
    
    #put previous iteration of centers in old_centers
    old_centers <- new_centers
    
    #put this iteration of centers in new_centers
    new_centers$x = temp$new_x
    new_centers$y = temp$new_y
    
    dist <- dist_between_centers(old_centers, new_centers)
    
    print(dist)
    if(dist < tau) {
      break
    }
  }
  return(list(centers=new_centers, clusters=m)) 
}

small_data <- geo_data_no_na[sample(dim(geo_data_no_na)[1], 10000, replace=F),]


ptm <- proc.time()
results <- k_means(small_data, 76, 10)
proc.time() - ptm
