# Modeling Social Data Final Report

## Obtaining and Filtering the Data

## Preliminary Data Analysis and Visualization

## Objective: Can we make “better” stops?

### Problem:

As you can see in the preliminary data analysis, the percentage of people that are arrested after being stopped is only ~6%. Our hypothesis is that we can increase the percentage of effective stops by using a classification algorithm like Naive Bayes or Logistic Regression. We will define an effective stop as one where an individual gets stopped and arrested for violating the law. For our algorithm, Naive Bayes and logistic regression classification produce results as probabilities which can be interpreted as probability for arrest. By setting a threshold on the probability, we hope to see if more effective stops can be made such that less innocent people are stopped, while still maximizing the number of criminal arrests.

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
- Height (Categorized differently for men and women):
  - 4: Tall
  - 3: Tall-Average
  - 2: Short-Average
  - 1: Short
- Age:
  - Kept as numeric data
- Precinct:
  - 76 different police precincts in Manhattan, Bronx, Queens, Brooklyn, and Staten Island
- Officer in Uniform:
  - 0: Not in uniform
  - 1: In uniform

### Additional Data Cleaning

After adding the feature set, we used `dplyr` to filter out entries with missing or misentered information. We filtered out entries where the age was greater than 100. We limited the race categories to White, Black, Asian, White-Hispanic, and Black-Hispanic which made up ~97% of the data. We also eliminated entries for "sex" and "build" which were marked as "Unknown." This data cleaning removed about 5% of entries, and given that our dataset is so large, did not have a substantial impact.

Percentages of data filtered out:
Age: 0.02%
Race: 3%
Sex:  1.5%
Build: 0.06%

Additionally, we reformatted height into categories. We adjusted for height in men and women, creating 4 categories of height based on these adjusted values. 

#4 = Tall, #3 = Tall-Average, #2 = Short-Average, #1 = Short


## Balancing Data

One of the initial problems we realized is that the data is imbalanced given that only 6% of stops lead to arrests. Consequently, our predictions for arrest or no-arrest could result in 94% accuracy by predicting every stop as no-arrest. For this reason, accuracy is not a good measure for success. Rather, we chose to plot the ROC curve to compare false positives to true positives. Additionally, in order to compensate for the imbalance in data, we split the data into two groups: arrests and no-arrest. Then, in the classification task, we randomly sample 30,000 data points from each set in order to generate a balanced data set of arrests and no-arrests.

## Naive Bayes

The first classification method we decided to try is the Naive Bayes algorithm. As you will see below, Naive Bayes gave poor and inconclusive results. Naive Bayes makes an independence assumption for features that is clearly not the case in our data.

### Model

In looking at the model, we examined the likelihood values for different features to see if any features had  arrest vs no arrest. Most of the probabilities remained fairly consistent. 

#### Example:
Carrying a Suspicious Object

 | No | Yes
--- | --- | ---
No Arrest | 0.97885914 | 0.02114086
Arrest | 0.92609709 | 0.07390291

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

