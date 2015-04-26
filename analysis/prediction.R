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
bad_rows <- match(c(3), data$arstmade)
data[bad_rows,] <- rep(NA, dim(data)[2])
data <- na.omit(data)

# Get the reasons for stop
predictor_data <- data.frame(arstmade=data$arstmade, cs_objcs=data$cs_objcs, cs_descr=data$cs_descr, 
                             cs_casng=data$cs_casng, cs_lkout=data$cs_lkout, cs_cloth=data$cs_cloth, 
                             cs_drgtr=data$cs_drgtr, cs_furtv=data$cs_furtv, cs_vcrim=data$cs_vcrim, 
                             cs_bulge=data$cs_bulge, ac_proxm=data$ac_proxm, ac_evasv=data$ac_evasv, 
                             ac_assoc=data$ac_assoc, ac_cgdir=data$ac_cgdir, ac_incid=data$ac_incid, 
                             ac_time=data$ac_time, ac_stsnd=data$ac_stsnd, ac_rept=data$ac_rept, 
                             ac_inves=data$ac_inves)

# Get vector of arrests
arrests <- data$arstmade

# Split data into arrests and no arrest
s <- which(arrests==1)
arrest_data <- predictor_data[s,]

s <- which(arrests==0)
no_arrest_data <- predictor_data[s,]

NUMBER_OF_NO_ARRESTS <- 50000
no_arrest_idx <- sample(nrow(no_arrest_data), NUMBER_OF_NO_ARRESTS)

balanced_data <- rbind(arrest_data, no_arrest_data[no_arrest_idx,])

# Show distribution of reasons
col_sums <- colSums(predictor_data)
barplot(col_sums)

# Choose the data set you wish to use (predictor_data or balanced data)
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


#########
# Logistic Regression
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
