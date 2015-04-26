#Notes

##Transforming Coordinates to Longitude and latitude

- Tranforming ambiguous x and y coordinates to latitude and longitude was a major PITA and decrypting this data made me feel like a bad ass data scientist. First I learned that the coordinates came from the New York Long Island 3104 State Plane Coordinate system. The US has 124 geographic zones which project latitude and longitude into cartesian coordinates. The New York Long Island SPC is a Lambert conformal conic projection. In order to project the data back to latitude and longitude coordinates, you need to use a cartographic projections library. Python has a library `pyproj` that can do this conversion. In order to construct a Projection object, you must convert the SPC into `Proj4` format. Here is the `Proj4` format for the New York Long Island SPC `"+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000.0000000001 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"`. Before projecting we need to convert the data from feet to meteres. After this conversion, we can use the inverse of the projection to convert the coordinates to latitude and longitude. After conversion the latitutde and longitude must be reversed. QED

##Prediction

- We decided to try and predict arrest using naive bayes and logistic regression. In choosing features we began with looking at the set of reasons that an officer can check off in a UF-250 form in stating why he or she decided to stop a civilian. Data collected that would have happened after the stop such as "did the suspect have a gun" would lead to bad predicions given that possesion of a weapon would almost certainly lead to arrest.  


###Features used
- cs_objcs reason for stop - carrying suspicious object
- cs_descr reason for stop - fits a relevant description
- cs_casng reason for stop - casing a victim or location
- cs_lkout reason for stop - suspect acting as a lookout
- cs_cloth reason for stop - wearing clothes commonly used in a crime
- cs_drgtr reason for stop - actions indicative of a drug transaction
- cs_furtv reason for stop - furtive movements
- cs_vcrim reason for stop - actions of engaging in a violent crime
- cs_bulge reason for stop - suspicious bulge
- ac_proxm additional circumstances - proximity to scene of offense
- ac_evasv additional circumstances - evasive response to questioning
- ac_assoc additional circumstances - associating with known criminals
- ac_cgdir additional circumstances - change direction at sight of officer
- ac_incid additional circumstances - area has high crime incidence
- ac_time additional circumstances - time of day fits crime incidence
- ac_stsnd additional circumstances - sights or sounds of criminal activity
- ac_rept additional circumstances - report by victim/witness/officer
- ac_inves additional circumstances - ongoing investigation


###Naive Bayes Results

        0     1
  0 87392  4143
  1 12730  2308

  AUC:  0.7008258

  Here is the problem, which is evident through the A-Priori probabilites
           0          1 
  0.93936259 0.06063741 


###Logistic Regression Results

             0      1
  FALSE 100098   6434
  TRUE      24     17

When plotting the probabilites you get all the mass towards the left


AUC: 0.7138809


##Balancing data

Given the inbalance in the data we sampled a data set that was more balanced. We used all 34000 arrests and a random sample of 50000 stops that did not lead to arrest

###Naive Bayes with Balanced Data

       0    1
  0 7739 3161
  1 2201 3359

  AUC 0.7009978


###Logistic Regression With Balanced Data

          0    1
  FALSE 8319 3575
  TRUE  1621 2945


  Big change in histogram

AUC: 0.717748
