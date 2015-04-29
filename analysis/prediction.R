library(glmnet)
library(dplyr)
library(ggplot2)
library(scales)
library(ROCR)
library(e1071)
library(ada)
##################
# Use naive bayes and logistic regression to find the probability of being arrested
# given reasons for being stopped
##################

DATA_FILE <- "../data/2012-data.csv"

# Import data and clean NA values
data <- read.csv(DATA_FILE, header=T, quote = "", na.strings = c("NA", "NULL"))
data <- na.omit(data)

# Remove arrest rows that equal 3
data <- data %>%
  filter(arstmade != 3)

# Get the reasons for stop
predictors <- data.frame(arstmade=data$arstmade, cs_objcs=data$cs_objcs, cs_descr=data$cs_descr, 
                             cs_casng=data$cs_casng, cs_lkout=data$cs_lkout, cs_cloth=data$cs_cloth, 
                             cs_drgtr=data$cs_drgtr, cs_furtv=data$cs_furtv, cs_vcrim=data$cs_vcrim, 
                             cs_bulge=data$cs_bulge, ac_proxm=data$ac_proxm, ac_evasv=data$ac_evasv, 
                             ac_assoc=data$ac_assoc, ac_cgdir=data$ac_cgdir, ac_incid=data$ac_incid, 
                             ac_time=data$ac_time, ac_stsnd=data$ac_stsnd, ac_rept=data$ac_rept, 
                             ac_inves=data$ac_inves)

# Adding some additional categorical data
predictors_with_categorical <- data.frame(predictor_data, race=data$race, 
                   offunif=data$offunif, sex=data$sex, build=data$build)

# Filter out bad categories
predictors_with_categorical <- predictors_with_categorical %>%
  # B: black, A: Asian, W: White, P: Black Hispanic, Q: White Hispanic
  filter(race=="B" | race=="W" | race=="A" | race=="P" | race=="Q") %>%
  # Filter out unknow sex (If you dont know the sex then your data is probably not great)
  filter(sex=="F" | sex=="M") %>%
  # H: Heavy, M: Medium, U: Muscular, T: Thin, Z: Unknown
  filter(build=="H" | build=="M" | build=="T" | build=="U" | build=="Z")

# Re-factor data
predictors_with_categorical$race <- factor(predictors_with_categorical$race)
predictors_with_categorical$sex <- factor(predictors_with_categorical$sex)
predictors_with_categorical$build <- factor(predictors_with_categorical$build)


# Takes in data and returns balanced set of data with all arrests and
# number of no arrests determined by param not_arrested_count
balance_data <- function(data, not_arrested_count) {
  s <- which(data$arstmade==1)
  arrest_data <- data[s,]
  
  s <- which(data$arstmade==0)
  no_arrest_data <- data[s,]
  
  no_arrest_idx <- sample(nrow(no_arrest_data), not_arrested_count)
  
  balanced_data <- rbind(arrest_data, no_arrest_data[no_arrest_idx,])
  
  return(balanced_data)
}


#######################################
# Predictions
#######################################
# Choose the data set you wish to use 
D <- balanced_data

# Split into test and train
ndx <- sample(nrow(D), floor(nrow(D) * 0.8))
x_train <- D[ndx, -1]
x_test <- D[-ndx, -1]
y_train <- D[ndx, 1]
y_test <- D[-ndx, 1]


# Use naive Bayes to build model
nb_model <- naiveBayes(x_train, factor(y_train))

# Build confusion matrix
table(predict(nb_model, x_test), factor(y_test))

# Get the probabilites of prediction
probs <- predict(nb_model, x_test, type="raw")
qplot(x=probs[, "1"], geom="histogram")

# Notice the confidence of some results- should see what features make less confident

# plot ROC curve
pred <- prediction(probs[, "1"], y_test)
perf_nb <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_nb)
performance(pred, 'auc')

#######
# Logistic regression
#######

# split into test and train
train <- D[ndx,]
test <- D[-ndx,]

# Build the model
lr_model <- glm(arstmade ~ ., data=train, family="binomial")

# Build a confusion matrix
table(predict(lr_model, test[,-1]) > 0, test$arstmade)

# plot histogram of predicted probabilities
lr_probs <- predict(lr_model, test[,-1], type="response")
qplot(x=lr_probs, geom="histogram")

# plot ROC curve
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)
performance(pred, 'auc')


#########
# Logistic Regression with lasso
#########

# Put x and y values in same data frame

# split into test and train
train <- D[ndx,]
test <- D[-ndx,]
y_train <- train$arstmade
y_test <- test$arstmade

train$arstmade <- NULL
test$arstmade <- NULL
x_train <- as.matrix(train)
x_test <- as.matrix(test)


# Build the model
lr_model <- cv.glmnet(x_train, factor(y_train), family="binomial", type.measure="auc")

# Build a confusion matrix
table(predict(lr_model, x_test, type="class"), factor(y_test))

# plot histogram of predicted probabilities
lr_probs <- predict(lr_model, x_test, type="response")
qplot(x=lr_probs[,1], geom="histogram")

# plot ROC curve
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)
performance(pred, 'auc')

arrests_vs_probs <- function(y_actual, y_pred_probs) {

  # Put the correct y values and predicted probabilites in a data frame
  df <- data.frame(y_actual=y_actual, y_pred_probs=y_pred_probs)
  # Shuffle the rows in the data frame
  df_shuffled <- df[sample(nrow(df), nrow(df)),]
  
  # Calculate percent of of stops vs the percent of arrests
  avg_stop_and_arrest <- df_shuffled %>%
      mutate(pct_arrests=cumsum(y_actual)/sum(y_actual)) %>%
      mutate(pct_stops = cumsum(rep(1, n()))/n())
  ggplot(avg_stop_and_arrest, aes(x=pct_stops, y=pct_arrests)) + geom_line()
  
  # Make a data frame so that it is ordered by highest to lowest probabilites
  df_sorted <- df[order(-df$y_pred_probs), ]
  
  # Calculate percent of stops vs the percent of arrests
  best_stops <- df_sorted %>%
    mutate(pct_arrests=cumsum(y_actual)/sum(y_actual)) %>%
    mutate(pct_stops = cumsum(rep(1, n()))/n())
  
  # Plot the tradeoff between the the predicted probability of stopping somewone
  # vs the percentage of people stopped
  ggplot(best_stops, aes(x=y_pred_probs, y=pct_arrests)) + geom_line()
  
  # Plot the percent of stops vs the percent of arrests
  ggplot(best_stops, aes(x=pct_stops, y=pct_arrests)) + 
    geom_line() +
    geom_line(data=avg_stop_and_arrest, aes(x=pct_stops, y=pct_arrests))
}
