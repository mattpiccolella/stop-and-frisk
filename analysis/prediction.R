library(glmnet)
library(dplyr)
library(ggplot2)
library(scales)
library(ROCR)
library(e1071)
##################
# Use naive bayes and logistic regression to find the probability of being arrested
# given reasons for being stopped
##################

DATA_FILE <- "data/2012-data-pruned.csv"


# Import data and clean NA values
data <- read.csv(DATA_FILE, header=T, quote = "", na.strings = c("NA", "NULL"))
data <- na.omit(data)

# Remove arrest rows that equal 3
data <- data %>%
  filter(arstmade != 3)

# Get the reasons for stop
predictors <- data.frame(arstmade=factor(data$arstmade), cs_objcs=factor(data$cs_objcs), cs_descr=factor(data$cs_descr), 
                             cs_casng=factor(data$cs_casng), cs_lkout=factor(data$cs_lkout), cs_cloth=factor(data$cs_cloth), 
                             cs_drgtr=factor(data$cs_drgtr), cs_furtv=factor(data$cs_furtv), cs_vcrim=factor(data$cs_vcrim), 
                             cs_bulge=factor(data$cs_bulge), ac_proxm=factor(data$ac_proxm), ac_evasv=factor(data$ac_evasv), 
                             ac_assoc=factor(data$ac_assoc), ac_cgdir=factor(data$ac_cgdir), ac_incid=factor(data$ac_incid), 
                             ac_time=factor(data$ac_time), ac_stsnd=factor(data$ac_stsnd), ac_rept=factor(data$ac_rept), 
                             ac_inves=factor(data$ac_inves))

# Adding some additional categorical data
predictors_with_categorical <- data.frame(predictors, race=data$race, 
                   offunif=data$offunif, sex=data$sex, build=data$build,
                   ht_feet=data$ht_feet, ht_inch=data$ht_inch, age=as.numeric(as.character(data$age)),
                   pct=factor(data$pct))

# Filter out bad categories
predictors_with_categorical <- predictors_with_categorical %>%
  # B: black, A: Asian, W: White, P: Black Hispanic, Q: White Hispanic
  filter(race=="B" | race=="W" | race=="A" | race=="P" | race=="Q") %>%
  # Filter out unknow sex (If you dont know the sex then your data is probably not great)
  filter(sex=="F" | sex=="M") %>%
  # H: Heavy, M: Medium, U: Muscular, T: Thin, Z: Unknown
  filter(build=="H" | build=="M" | build=="T" | build=="U" | build=="Z") %>%
  # Filter out age greater than 100
  filter(age <= 100)

# Re-factor data
predictors_with_categorical$race <- factor(predictors_with_categorical$race)
predictors_with_categorical$sex <- factor(predictors_with_categorical$sex)
predictors_with_categorical$build <- factor(predictors_with_categorical$build)
predictors_with_categorical$offunif <- factor(predictors_with_categorical$offunif)

#Categorize height into discrete categories
NUM_INCHES_IN_FOOT <- 12
total_ht_inches <- as.numeric(as.character(predictors_with_categorical$ht_feet))*NUM_INCHES_IN_FOOT + 
  as.numeric(as.character(predictors_with_categorical$ht_inch))

categorical_height<- numeric(nrow(predictors_with_categorical))

is_male = (predictors_with_categorical$sex == "M")
categorical_height = ((total_ht_inches >= 72) & is_male) * 4 +
  ((total_ht_inches >= 67 & total_ht_inches < 72) & is_male) * 3 +
  ((total_ht_inches >= 63 & total_ht_inches < 67) & is_male) * 2 +
  ((total_ht_inches < 63) & is_male) * 1 +
  ((total_ht_inches >= 70) & !is_male) * 4 +
  ((total_ht_inches >= 65 & total_ht_inches < 70) & !is_male) * 3 +
  ((total_ht_inches >= 60 & total_ht_inches < 65) & !is_male) * 2 +
  ((total_ht_inches < 60) & !is_male) * 1

predictors_with_categorical$categorical_height <- factor(categorical_height)

# Previously, we had thought we wanted to make factors out of the person's age.
# However, after seeing ultimately enchanged results, we changed it back.
# age <- as.numeric(as.character(predictors_with_categorical$age))
# is_older_15 = as.numeric(age>15)
# is_older_18 = as.numeric(age>18)
# is_older_21 = as.numeric(age>21)
# is_older_26 = as.numeric(age>26)
# is_older_35 = as.numeric(age>35)
# is_older_50 = as.numeric(age>50)
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_15))
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_18))
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_21))
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_26))
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_35))
# predictors_with_categorical <- cbind(predictors_with_categorical,factor(is_older_50))

# Remove unecessary data
# predictors_with_categorical$age <- NULL
predictors_with_categorical$ht_feet <- NULL
predictors_with_categorical$ht_inch <- NULL

# Takes in data and returns balanced set of data with all arrests and
# number of no arrests determined by param not_arrested_count
balance_data <- function(data, arrest_count, non_arrest_count) {
  s <- which(data$arstmade==1)
  arrest_data <- data[s,]
  
  s <- which(data$arstmade==0)
  no_arrest_data <- data[s,]
  
  no_arrest_idx <- sample(nrow(no_arrest_data), non_arrest_count)
  
  arrest_idx <- sample(nrow(arrest_data), arrest_count)
  
  balanced_data <- rbind(arrest_data[arrest_idx,], no_arrest_data[no_arrest_idx,])
  
  return(balanced_data)
}

#########
# Function that prints useful graphs that show the percentage of stops vs percentage of arrests
# and probability of arrest vs percentage of arrests
######

arrests_vs_probs <- function(y_actual, y_pred_probs) {
  
  y_actual <- as.numeric(as.character(y_actual))
  
  # For logistic regression get vector of probabilites
  # If naive bayes, we have matrix with col 1 prob no-arrest and col 2 prob of arres. Must choose col 2
  # For logistic regression with lasso get a matrix with one column
  if(!is.vector(y_pred_probs)) {
    if(ncol(y_pred_probs) == 2) {
      y_pred_probs <- y_pred_probs[,2]
    } else {
      y_pred_probs <- y_pred_probs[,1]
    }
  }
  
  # Put the correct y values and predicted probabilites in a data frame
  df <- data.frame(y_actual=y_actual, y_pred_probs=y_pred_probs)
  # Shuffle the rows in the data frame
  df_shuffled <- df[sample(nrow(df), nrow(df)),]
  
  # Calculate percent of of stops vs the percent of arrests
  avg_stop_and_arrest <- df_shuffled %>%
    mutate(pct_arrests=cumsum(y_actual)/sum(y_actual)) %>%
    mutate(pct_stops = cumsum(rep(1, n()))/n())
  plot1 <- ggplot(avg_stop_and_arrest, aes(x=pct_stops, y=pct_arrests)) + 
    geom_line() +
    xlab("Percentage of Stops") +
    ylab("Percentage of Arrests") +
    ggtitle("Percentage of Arrests vs Stops")
  
  # Make a data frame so that it is ordered by highest to lowest probabilites
  df_sorted <- df[order(-df$y_pred_probs), ]
  
  # Calculate percent of stops vs the percent of arrests
  best_stops <- df_sorted %>%
    mutate(pct_arrests=cumsum(y_actual)/sum(y_actual)) %>%
    mutate(pct_stops = cumsum(rep(1, n()))/n())
  
  # Plot the tradeoff between the the predicted probability of stopping somewone
  # vs the percentage of people stopped
  plot2 <- ggplot(best_stops, aes(x=y_pred_probs, y=pct_arrests)) + 
    geom_line() +
    xlab("Probability of Arrest") +
    ylab("Percentage of Arrests") +
    ggtitle("Probability of Arrest vs Percentage of Arrests")
  
  # Plot the percent of stops vs the percent of arrests
  plot3 <- ggplot(best_stops, aes(x=pct_stops, y=pct_arrests)) + 
    geom_line() +
    geom_abline(intercept = 0, slope = 1, colour="blue", linetype="dashed") +
    xlab("Percentage of Stops") +
    ylab("Percentage of Arrests") +
    ggtitle("Percentage of Stops vs Arrests Sorted by Highest Likelihood of Arrest")
  
  print(plot1)
  print(plot2)
  print(plot3)
  
}

#######
# Function to find most predictive features in naive bayes
# Looks at differnece between predicting yes arrest and no arrest
# and finds the largest differences
########

naive_bayes_diffs <- function(nb_model) {
  list_of_tables <- nb_model$tables
  num_of_tables <- length(list_of_tables)
  ret <- list()
  for (i in (1:num_of_tables)) {
    diff <- list_of_tables[[i]][1,] - list_of_tables[[i]][2,]
    ret[[i]] <- c(list_of_tables[i], diff)
  }
  return(ret)
}


#######################################
# Predictions
#######################################
# Choose the data set you wish to use 
ARREST_COUNT <- 30000
NO_ARREST_COUNT <- 400000
D <- predictors_with_categorical

# Split into test and train
PCT_TRAIN <- 0.8

ndx <- sample(nrow(D), floor(nrow(D) * PCT_TRAIN))

##########
# Naive Bayes
##########
NB_OUTPUT_DATA <- "output/nb_data.txt"
NB_OUTPUT_GRAPHS <- "output/nb_graphs.pdf"
sink(NB_OUTPUT_DATA)

x_train <- D[ndx, -1]
x_test <- D[-ndx, -1]
y_train <- D[ndx, 1]
y_test <- D[-ndx, 1]


# Use Naive Bayes to build model
nb_model <- naiveBayes(x_train, factor(y_train))
print("Naive Bayes Model")
print(nb_model)
print("Naive Bayes Differences in Probabilites")
print(naive_bayes_diffs(nb_model))

# Build confusion matrix
nb_table <- table(predict(nb_model, x_test), factor(y_test))
print("Naive Bayes Confusion Matrix")
print(nb_table)

# Get the probabilites of prediction
probs <- predict(nb_model, x_test, type="raw")
nb_pred_prob <- qplot(x=probs[, "1"], geom="histogram") +
  xlab("Probability") +
  ggtitle("Naive Bayes Probabilites")

# Notice the confidence of some results- should see what features make less confident

# plot ROC curve
pred <- prediction(probs[, "1"], y_test)
perf_nb <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_nb)

print("Naive Bayes Performance")
print(performance(pred, 'auc'))
sink()

#Print Graphs
pdf(NB_OUTPUT_GRAPHS)
print(nb_pred_prob)
plot(perf_nb)
arrests_vs_probs(y_test, probs) 
dev.off()


#######
# Logistic regression
#######
LR_OUTPUT_DATA <- "output/lr_data.txt"
LR_OUTPUT_GRAPHS <- "output/lr_graphs.pdf"
sink(LR_OUTPUT_DATA)

# split into test and train
train <- D[ndx,]
test <- D[-ndx,]

# Build the model
lr_model <- glm(arstmade ~ ., data=train, family="binomial")
print("Logistic Regression Model")
print(lr_model)
print("Get 10 best predictors for Arrest")
print(tail(sort(lr_model$coefficients), 10))

# Build a confusion matrix
lr_table <- table(predict(lr_model, test[,-1]) > 0, test$arstmade)
print("Logistic Regression Confusion Matrix")
print(lr_table)

# plot histogram of predicted probabilities
lr_probs <- predict(lr_model, test[,-1], type="response")
lr_pred_prob <- qplot(x=lr_probs, geom="histogram")  +
  xlab("Probability") +
  ggtitle("Logistic Regression Probabilites")

# plot ROC curve
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)

print("Logistic Regression AUC")
print(performance(pred, 'auc'))
sink()

#Print the graphs
pdf(LR_OUTPUT_GRAPHS)
print(lr_pred_prob)
plot(perf_lr)
arrests_vs_probs(test$arstmade, lr_probs) 
dev.off()


#########
# Logistic Regression with lasso
#########
LASSO_OUTPUT_DATA <- "output/lasso_data.txt"
LASSO_OUTPUT_GRAPHS <- "output/lasso_graphs.pdf"
sink(LASSO_OUTPUT_DATA)

# Put x and y values in same data frame

# split into test and train
train <- D[ndx,]
test <- D[-ndx,]
y_train <- train$arstmade
y_test <- test$arstmade

# Convert categories into indicator variables
x_factors_train <- model.matrix(arstmade~., data=train)[,-1]
x_factors_test <- model.matrix(arstmade~., data=test)[,-1]
x_train <- as.matrix(x_factors_train)
x_test <- as.matrix(x_factors_test)


# Build the model
lasso_model <- cv.glmnet(x_train, factor(y_train), family="binomial", type.measure="auc")
print("Lasso Model")
print(lasso_model)

# Build a confusion matrix
lasso_table <- table(predict(lasso_model, x_test, type="class"), factor(y_test))
print("Lasso Confusion Matrix")
print(lasso_table)

# plot histogram of predicted probabilities
lr_probs <- predict(lasso_model, x_test, type="response")
lasso_pred_prob <- qplot(x=lr_probs[,1], geom="histogram")  +
  xlab("Probability") +
  ggtitle("Logistic Regression with Lasso Probabilites")

# plot ROC curve
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)

print("Lasso AUC")
print(performance(pred, 'auc'))


get_best_features <- function(crossval) {
  coefs <- coef(crossval, s="lambda.min")
  coefs <- as.data.frame(as.matrix(coefs))
  names(coefs) <- "weight"
  coefs$features <- row.names(coefs)
  row.names(coefs) <- NULL
  subset(coefs, weight != 0)
}

# Get Most important important features
feats <- get_best_features(lasso_model)
feats <- feats[order(feats$weight),]

print("Lasso Most Predictive Features")

print(head(feats, 10))
print(tail(feats, 10))

sink()


pdf(LASSO_OUTPUT_GRAPHS)
print(lasso_pred_prob)
plot(perf_lr)
arrests_vs_probs(y_test, lr_probs) 
dev.off()

####
# Adaboost
####

SMALLER_SAMPLE_SIZE = 30000
SMALL_D <- D[sample(nrow(D), SMALLER_SAMPLE_SIZE),]

train <- SMALL_D[ndx,]
test <- SMALL_D[-ndx,]

ada_model <- ada(arstmade ~., data=train, verbose=TRUE, na.action=na.rpart)

ada_model <- addtest(ada_model, test.x=test[,-1], test.y=test$arstmade)

# Plot the model
plot(ada_model, test=T)

# Plot most important features
varplot(ada_model)

# Predict on test data
predictions <-predict(ada_model, newdata=test, type="vector")

pred <- prediction(predictions, test[,1])
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)

print(performance(pred, 'auc'))



#####
# Define Heuristic 
#####

# Choose the data set you wish to use 

D <- predictors_with_categorical

#Take out precinct information
D$pct = NULL
D$ht_inch = NULL
D$ht_feet = NULL 

# Split into test and train
PCT_TRAIN <- 0.8

ndx <- sample(nrow(D), floor(nrow(D) * PCT_TRAIN))

# split into test and train
train <- D[ndx,]
test <- D[-ndx,]

# Build the model
lr_model <- glm(arstmade ~ ., data=train, family="binomial")

# Remove all negative coefficeincts
lr_model$coefficients[lr_model$coefficients < 0] = 0 

# Get the predicted probabilites
lr_probs <- predict(lr_model, test[,-1], type="response")

# plot ROC curve. Notice that AUC does not get significantly reduced
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)

print("Logistic Regression AUC")
print(performance(pred, 'auc'))

#Look at predictive features

sort(lr_model$coefficients)
