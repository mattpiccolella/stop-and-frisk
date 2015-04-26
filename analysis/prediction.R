library(glmnet)
library(dplyr)
library(ggplot2)
library(scales)
library(ROCR)
library(e1071)
library(ada)
##################
# Use logistic regression to find the probability of being arrested
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
predictor_data <- data.frame(cs_objcs=data$cs_objcs, cs_descr=data$cs_descr, cs_casng=data$cs_casng,
                             cs_lkout=data$cs_lkout, cs_cloth=data$cs_cloth, cs_drgtr=data$cs_drgtr,
                             cs_furtv=data$cs_furtv, cs_vcrim=data$cs_vcrim, cs_bulge=data$cs_bulge,
                             ac_proxm=data$ac_proxm, ac_evasv=data$ac_evasv, ac_assoc=data$ac_assoc, 
                             ac_cgdir=data$ac_cgdir, ac_incid=data$ac_incid, ac_time=data$ac_time, 
                             ac_stsnd=data$ac_stsnd, ac_rept=data$ac_rept, ac_inves=data$ac_inves)

# Get vector of arrests
arrests <- data$arstmade

# Show distribution of reasons
col_sums <- colSums(predictor_data)
barplot(col_sums)

# Split into test and train
ndx <- sample(nrow(predictor_data), floor(nrow(predictor_data) * 0.8), replace=F)
x_train <- predictor_data[ndx,]
x_test <- predictor_data[-ndx,]
y_train <- arrests[ndx]
y_test <- arrests[-ndx]


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
lr_data <- data.frame(predictor_data, arstmade=data$arstmade)

# split into test and train
train <- lr_data[ndx,]
test <- lr_data[-ndx,]

# Build the model
lr_model <- glm(arstmade ~ ., data=train, family="binomial")

# Build a confusion matrix
table(predict(lr_model, test[,-18]) > 0, test$arstmade)

# plot histogram of predicted probabilities
lr_probs <- predict(lr_model, test[,-18], type="response")
qplot(x=lr_probs, geom="histogram")

# plot ROC curve
pred <- prediction(lr_probs, test$arstmade)
perf_lr <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_lr)
performance(pred, 'auc')

########
# Adaboost
########

ptm <- proc.time()
ada_model <- ada(arstmade ~., data=train, verbose=TRUE, na.action=na.rpart)
proc.time() - ptm

ptm <- proc.time()
ada_model <- addtest(ada_model, test.x=test[,-18], test.y=test$arstmade)
proc.time() - ptm

# Plot the model
plot(ada_model, test=T)

# Plot most important features
varplot(ada_model)

# Predict on test data
predictions <-predict(ada_model, newdata=test, type="vector")

# Test accuracy - may not be best measure as much less arrests
sum(predictions==test$arstmade)/length(predictions)

# Test what percentage of arrest predictions were correct
s<-which(test$arstmade==1)
sum(predictions[s]==test$arstmade[s])/length(predictions[s])

# Test what percentage of no arrest pereictions were correct
s<-which(test$arstmade==0)
sum(predictions[s]==test$arstmade[s])/length(predictions[s])

