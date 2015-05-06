# Modeling Social Data Final Report
## Zachary Gleicher, Matt Piccolella, Edo Roth

## Obtaining and Filtering the Data



## Preliminary Data Analysis and Visualization



## Objective: Can we make “better” stops?

### Problem:

As you can see in the preliminary data analysis, the percentage of people that are arrested after being stopped is only X%. Our hypothesis is that we can increase the percentage of effective stops by using a classification algorithm like Naive Bayes or Logistic Regression. We will define an effective stop as one where an individual gets stopped and arrested for violating the law. For our algorithm, naive bayes and logistic regression classification result in probabilities of arrest and identify features that are most predictive in determining arrest. Given the probabilities, an effective threshold can be set to optimize the effectiveness of stops. Given a higher threshold, less arrests will be made, but also less innocent people will be stopped. Finally, we plan to identify the features that are most predictive in determining arrest. 

### Choosing Features:

When an officer conducts a stop, he or she must fill out an UF-250 form which includes “yes or no” fields for an officer to identify why he or she decided to stop the suspect. We used these as the foundations for building our model. We then went through the dataset and looking for other useful features that could help predict arrests that are not necessarily “reasons for stop.” Race is an example of an additional feature. You can see the full list below. We made sure to exclude any features that would have happened after the stop. For example, the dataset has an indicator field that asks, "did the suspect have a weapon?" Although a “yes” response almost surely correlated with an arrest, this feature should not be used as given that the discovery of a weapon only happens after an officer has stopped and frisked an individual.

#### List of Reasons For Stop

Below you will see categories in the UF-250 form that officers can fill out as reasons for stop. All these categories are filled out with a “Y” for yes an “N” for no.

- Reason for stop - carrying suspicious object
- Reason for stop - fits a relevant description
- Reason for stop - casing a victim or location
- Reason for stop - suspect acting as a lookout
- Reason for stop - wearing clothes commonly used in a crime
- Reason for stop - actions indicative of a drug transaction
- Reason for stop - furtive movements
- Reason for stop - actions of engaging in a violent crime
- Reason for stop - suspicious bulge
- Additional circumstances - proximity to scene of offense
- Additional circumstances - evasive response to questioning
- Additional circumstances - associating with known criminals
- Additional circumstances - change direction at sight of officer
- Additional circumstances - area has high crime incidence
- Additional circumstances - time of day fits crime incidence
- Additional circumstances - sights or sounds of criminal activity
- Additional circumstances - report by victim/witness/officer
- Additional circumstances - ongoing investigation

#### Additional Features:

As described above, we included additional features which may not be technical reasons for stop, but do contribute to an officer’s decision to stop a suspect. Below, you will see the additional features.

- Race: 
  - B: Black
  - W: White
  - A: Asian
  - P: Black Hispanic
  - W: White Hispanic
- Sex: 
  - F: Female
  - M: Male
- Build:
  - H: Heavy
  - M: Medium
  - T: Thin
  - U: Muscular
  - Z: Unknown
- Height
  -4: Tall
  -3: Tall-Average
  -2: Short-Average
  -1: Short
- Age (Boolean categories)
  -Over 15 years old
-Over 18 years old
-Over 21 years old
-Over 26 years old
-Over 15 years old
-Over 35 years old
  -Over 50 years old

- Precinct ?
  - Proxy for location but probably has a lot of confounding variables

### Cleaning Data Further

When looking at the data, we realized there were a lot of bad data points that were either clearly misentered, or not useful for our analysis. As discussed before, we first only selected those features that would be useful to classify whether an arrest should be made or not. We then filtered out some points -- for instance, we had many values of age that that were over 200 and clearly misentered, so we limited our analysis to individuals under 100 years of age, a reasonable assumption as we only take out a miniscule percentage of values, most of which are likely incorrect. We also filtered out unknown values for race, sex, and build -- as we have so much data, we figured this would not assist in our analysis, and does not represent any significant portion of the population.

Percentages of data filtered out:
Age: 0.02%
Race: 3%
Sex:  1.5%
Build: 0.06%

Finally, we took the columns of height in inches and feet and combined them to form a total height column, categorizing them into discrete values. We adjusted for height in men and women, creating 4 categories of height based on these adjusted values. 

#4 = Tall, #3 = Tall-Average, #2 = Short-Average, #1 = Short

Age was also reduced to smaller buckets of discrete value for use in classification -- we created boolean columns is_older_15, is_older_18, is_older_21, is_older_26, is_older_35, is_older_50 to give us a better means to classify the categorical age of individuals stopped.

## Balancing Data

One of the initial problems we realized is that the data is imbalanced given that only 6% of stops lead to arrests. Consequently, our predictions for arrest or no-arrest could result in 94% accuracy by predicting every stop as no-arrest. For this reason, accuracy is not a good measure for success. Rather, we chose to plot the ROC curve to compare false positives to true positives. Additionally, in order to compensate for the imbalance in data, we split the data into two groups: arrests and no-arrest. Then, in the classification task, we randomly sample 30,000 data points from each set in order to generate a balanced data set of arrests and no-arrests.

## Naive Bayes

The first classification algorithm we decided to try is naive bayes. Naive bayes is probably not the best choice for classification given that the features in the dataset are not independent. In this classification.

### Model

In looking at the model, we tried to identify probabilities that could help distinguish arrest vs no arrest. Most of the probabilities remained fairly consistent. 

#### Example:
               cs_objcs
factor(y_train)          0          1
              0 0.97885914 0.02114086
              1 0.92609709 0.07390291

In this example we see that for ~7% arrests, the officer noted that the suspect carried a suspicious object, conversely, ~2% of non-arrests occurred when an officer noted that the suspect was holding a suspicious object. This spread is not very large

### Most decisive Features

             
               cs_descr
factor(y_train)         0         1
              0 0.8453423 0.1546577
              1 0.6886918 0.3113082


               cs_casng
factor(y_train)         0         1
              0 0.6338087 0.3661913
              1 0.8301274 0.1698726

               ac_rept
factor(y_train)         0         1
              0 0.8815675 0.1184325
              1 0.6976337 0.3023663

               offunif
factor(y_train)         0         1
              0 0.2432714 0.7567286
              1 0.3628813 0.6371187



               race
factor(y_train)          A              B            P            Q            W
              0 0.03156534 0.55312318 0.06976065 0.24714369 0.09840714
              1 0.04021984 0.51328171 0.07698393 0.26371888 0.10579565

Notice that all the races had nearly equal probabilities for arrest and no arrest, but the only race that had a higher probability of no arrest was black


### Probability Graph

**INSERT GRAPH**

In this graph, you will notice that there is higher probability mass towards predicting arrests and consequently our confusion matrix has a higher rate of true positives than true negatives.

### Confusion Matrix

    True Values
          0      1
Predicted     0 3511 1680
Values    1 2450 4359


### ROC Curve

**INSERT GRAPH**

AUC 0.7199524

## Additional Graphs

**INSERT GRAPH**

This graph represents the percentage of stops vs percentage of arrests where the data is sorted by the . has a straight line with a slope of ~1,  the weakness of the naive bayes classifier. The data is organized such that the data is ordered from highest probability of arrest to lowest probability of arrest. Consequently, we hope to get a curve with a greater probability for arrest  

## Logistic Regression

### Probability Graph

### Confusion Matrix

### Best Indicators

## Logistic Regression with Lasso

### Probability Graph

### Confusion Matrix

### Best Indicators

## Best Predictors

