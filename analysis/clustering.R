require(dplyr)
require(ggplot2)

DATA_FILE <- "data/2012.csv"

######################
# Preliminary data analysis
######################

# Read in data
data <- read.csv(DATA_FILE, header=T)

# Get the number of unique police precincts, and make this the number of clusters
NUM_CLUSTERS <- 20

# Extract x and y coordinates and place in data frame
geo_data <- data.frame(x=data$xcoord, y=data$ycoord)
# Omit data without geo_data
geo_data_no_na <- na.omit(geo_data)
# List of valid rows with geo_data
valid_rows <- strtoi(rownames(geo_data_no_na))


####################
# R k-means
####################

ptm <- proc.time()
model <- kmeans(geo_data_no_na, NUM_CLUSTERS)
proc.time() - ptm

###################
# Plotting results
###################

# Add cluster to data frame
data_with_clusters <- data.frame(geo_data_no_na, cluster = factor(model$cluster))
# Get cluster centers
centers <- as.data.frame(model$centers)
# Make a smaller selection so that it can be plotted
smaller_sample <- data_with_clusters[sample(dim(data_with_clusters)[1], 50000, replace=F),]

ggplot(data=smaller_sample, aes(x=x, y=y, color=cluster )) + 
  geom_point() + 
  geom_point(data=centers, aes(x=x,y=y, color='Center')) +
  ggtitle("The Centers of Stop and Frisk")
ggsave("output/clustering-map.pdf")

######################
# Homemade k-means
#####################

# Helper function to find euclidean distance between two points
dist <- function(row, point) {
  x1 <- point[1]
  y1 <- point[2]
  x2 <- row[1]
  y2 <- row[2]
  
  sum_of_squared_diff <- (x2-x1)^2 + (y2-y1)^2
  return(sqrt(sum_of_squared_diff))
}

# Helper function to get min distance between point and centers
best_centers <- function(row, centers) {
  return(which.min(apply(centers, 1, dist, point=row)))
}

# Helper function to get distance between old centers and new centers
dist_between_centers <- function(old_centers, new_centers) {
  temp <- data.frame(x1=old_centers$x, y1<-old_centers$y, x2=new_centers$x, y2=new_centers$y)
  dist <- apply(temp, 1, function(row) sqrt((row[1]-row[3])^2 + (row[2]-row[4])^2))
  return(sum(dist))
}

# k_means alg 
# param data: data frame containing x and y coordinates 
# param k: number of clusters 
# param tau: threshold parameter
k_means <- function(data, k, tau) {
  data_size <- dim(data)[1]
  # m is a vector where the index represents the cluster of the ith data point
  m <- c()
  # Sample k random centers
  old_centers <- data[sample(data_size, k, replace=F),]
  
  # Make sure the centers are unique
  while(sum(duplicated(old_centers))!= 0) {
    old_centers <- data[sample(data_size, k, replace=F),]
  }
  new_centers <- old_centers
  
  # Iterate until convergance
  repeat {
    # Assign each data point to closeset center with smallest euclidean distance
    m <- apply(data, 1, best_centers, centers=new_centers) 
    
    # Recompute each center as the average of all points assigned to it    
    data_with_cluster <- data.frame(data, cluster=m)
    temp <- data_with_cluster %>%
      group_by(cluster) %>%
      summarize(new_x=sum(x)/n(), new_y=sum(y)/n())
    
    # Put previous iteration of centers in old_centers
    old_centers <- new_centers
    
    # Put this iteration of centers in new_centers
    new_centers$x = temp$new_x
    new_centers$y = temp$new_y
    
    # Find the distance
    dist <- dist_between_centers(old_centers, new_centers)
    
    # Finish iterating when distance is smaller than tau
    print(dist)
    if(dist < tau) {
      break
    }
  }
  # Return a list containing a vector of centers and vector containing assignment of cluster
  return(list(centers=new_centers, clusters=m)) 
}

small_data <- geo_data_no_na[sample(dim(geo_data_no_na)[1], 10000, replace=F),]

# Uncomment this if you want to run. WARNING: it takes a long time.
# ptm <- proc.time()
# results <- k_means(small_data, NUM_CLUSTERS, 10)
# proc.time() - ptm
