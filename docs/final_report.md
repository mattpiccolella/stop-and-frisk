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

Additionally, we reformatted height into categories: "Tall," "Tall-Average," "Short-Average" "Short". We adjusted for height in men and women, creating 4 categories of height based on these adjusted values. 

## Naive Bayes

The first classification method we decided to try is the Naive Bayes algorithm.

### Model

Given the imbalance of the data, with ~94% no-arrests, be thought that the Naive Bayes classifier would perform better if we balanced the data. The reason for this is that the prior distribution of the classes, would lead to significantly higher posterior probabilities for no-arrest. We split the data into two groups: arrests and no-arrest. Then, in the classification task, we randomly sample 30,000 data points from each set in order to generate a balanced data set of arrests and no-arrests. After balancing the data, however, the ROC curve did not improve.

One of the initial problems we realized is that the data is imbalanced given that only 6% of stops lead to arrests. Consequently, our predictions for arrest or no-arrest could result in 94% accuracy by predicting every stop as no-arrest. For this reason, accuracy is not a good measure for success. Rather, we chose to plot the ROC curve to compare false positives to true positives. Additionally, in order to compensate for the imbalance in data, 

In looking at the model, we examined the likelihood values for the features to see which differences in likelihood would lead to a greater difference in the posterior probability for determining whether the data should be classified as arrest of no-arrest. Most of the likelihood estimates that remained fairly consistent for both classes. 

#### Example:
Reason for Stop: Carrying a Suspicious Object

 | No | Yes
--- | --- | ---
No Arrest | 0.97885914 | 0.02114086
Arrest | 0.92609709 | 0.07390291

In this example we see that for ~7% arrests, the officer noted that the suspect carried a suspicious object, conversely, ~2% of non-arrests occurred when an officer noted that the suspect was holding a suspicious object. This spread is not very large, which will lead to a relatively small difference when using Naive Bayes to calculate the difference in likelihood between arrest and no arrest.

### Most decisive Features

Here are the features with the largest difference in likelihood between arrest and no arrest. All other features had differences less than 0.1.

Reason For Stop: Fits a Relevant Description

 | No | Yes
--- | --- | ---
No Arrest | 0.8453423 | 0.1546577
Arrest | 0.6886918 | 0.3113082

Reason for Stop: Casing a Victim or Location

 | No | Yes
--- | --- | ---
No Arrest | 0.6338087 | 0.3661913
Arrest | 0.8301274 | 0.1698726

Additional Circumstances: Report by Victim/Witness/Officer

 | No | Yes
--- | --- | ---
No Arrest | 0.8815675 | 0.1184325
Arrest | 0.6976337 | 0.3023663

Was the Officer in Uniform

 | No | Yes
--- | --- | ---
No Arrest | 0.2432714 | 0.7567286
Arrest | 0.3628813 | 0.6371187



### Probability Graph

**INSERT GRAPH**

In this graph, you will notice that there is higher probability mass towards predicting arrests and consequently our confusion matrix has a higher rate of true positives than true negatives.

### ROC Curve

**INSERT GRAPH**

AUC 0.7199524

It is important to use the ROC curve to evaluate the model because imbalanced data can lead to deceiving results when talking about accuracy. For example, if I had a dumb model that predicted no-arrest for every data point, I would get 94% accuracy. 

## Logistic Regression

Additionally, we built a logistic regression model to classify the data as arrest and non-arrest. Since the feature space is small compared to the size of the dataset, we did not believe that a regularization method like lasso would lead to a dramatic improvement. We tested this hypothesis by implementing logistic regression model with lasso, and it performed the same. The logistic regression model did outperform the the Naive Bayes model by increasing the AUC by about 0.1

### Probability Graph

Notice that this graph, very much like the Naive Bayes model, predicts more heavily on 


## Results

Using the logistic regression model, we built a model that could lead to better predictions for arrests. 

**INSERT GRAPH**

This graph shows the predicted probability of arrest from the logistic regression model verses the percentage of arrests made. As you can see, the curves falls very quickly, which is due to the fact that the model predicts non-arrests much more heavily.

**INSERT GRAPH**

Here, you can see a graph comparing the percentage of stops vs the percentage of arrests. The data has been sorted by the highest probabilities. Intuitively, we want to increase the area between the blue dashed line and the black curve. More area means that our classification algorithm can predict more arrests in a given set of stops. This graph shows that you can reduce the number of innocent stops by 50% while only reducing the number of guilty stops by about 20%. With the combination of both graphs, a probability threshold can be set in order to find a better trade off between minimizing the number of stops of innocent people, while still maximizing the number of stops of guilty people.

Here is the list of the 10 most predictive features for arrest given a stop: 

"Get 10 best predictors for Arrest"
    pct42     pct25     pct19     pct44    pct105    pct102 cs_drgtr1      pct9  ac_rept1 cs_objcs1 
0.5008073 0.5639895 0.6069064 0.6222683 0.6400148 0.7004087 0.8372146 0.8652883 0.9516741 1.0960916 


Using our model would be impractical to use on the field given the amount of time it would take to fill out the variables to determine whether someone should be stopped. Therefore, we limit the logistic regression model such that all negative coefficients are set to 0. This update reduced our AUC by about 0.07, but still performs better than using no model. A police officer can then focus on these features to help determine whether someone should be stopped or not. 





