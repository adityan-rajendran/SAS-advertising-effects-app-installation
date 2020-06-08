/* Project */

/* Directory set as current folder */
LIBNAME DIR './';

/* Part 1. Logistic Regression Analysis */

/* Question 1.1 - Model Evolution */
/* Data import */
data mobilead;
  set DIR.mobilead;
  
  /* One hot encoding for categorical variables */
  if device_platform_class = "android" then platform = 1; else platform = 0;
run;

/* Check correlations - device_width*resolution 0.81 - device_height*resolution 0.76 */
proc corr data=mobilead;
  var device_volume wifi resolution device_height device_width;
run;

/* Rare event checking */	
proc freq data=mobilead;
table install;
run;

/* Missing values check */
proc freq data=mobilead;
table publisher_id_class device_os_class device_make_class wifi platform device_height device_width device_volume / missprint;
run;


/* Splitting into training and test sets */
proc surveyselect data=mobilead out=mobilead_sampled outall samprate=0.8 seed=10;
run;
data train_mobilead test_mobilead;
 set mobilead_sampled;
 if selected then output train_mobilead; 
 else output test_mobilead;
run;

/* Logistic Regression */
/* Model 1: AIC - 8758, BIC - 9081 */
proc logistic data=train_mobilead;
 class publisher_id_class device_os_class device_make_class;
 logit: model install (event='1') = device_volume wifi resolution device_height 
 device_width publisher_id_class device_os_class device_make_class platform /firth;
 title "Model 1: Using existing variables";
run;

/* Model 2: AIC - 8796, BIC - 9014 */
proc logistic data=train_mobilead;
 class publisher_id_class device_make_class;
 logit: model install (event='1') = wifi resolution device_height 
 device_width publisher_id_class device_make_class /firth;
 title "Model 2: Eliminating insignificant variables";
run;

/* Model 3: AIC - 8724, BIC - 9066*/
proc logistic data=train_mobilead;
 class publisher_id_class device_os_class device_make_class;
 logit: model install (event='1') = device_volume wifi resolution device_height 
 device_width publisher_id_class device_os_class device_make_class platform
 device_height*device_width resolution*device_height resolution*device_width /firth;
 title "Model 3: Using interaction terms";
run;

/* Model 4: AIC - 8655, BIC - 9025 - BEST MODEL*/
proc logistic data=train_mobilead;
 class publisher_id_class device_make_class device_os_class;
 logit: model install (event='1') = device_volume wifi resolution device_height 
 device_width publisher_id_class device_os_class device_make_class platform
 resolution*device_height resolution*device_width 
 resolution*resolution device_height*device_height device_width*device_width /firth;
 title "Model 4: Using quadratic terms";
run;

/* Question 1.2 - ROC curve - AUC: 0.6118 */
proc logistic data=train_mobilead outmodel=logit_outmodel ;
 class publisher_id_class device_make_class device_os_class;
 logit: model install (event='1') = device_volume wifi resolution device_height 
 device_width publisher_id_class device_os_class device_make_class platform
 resolution*device_height resolution*device_width 
 resolution*resolution device_height*device_height device_width*device_width /firth;
 score data=test_mobilead out=test_predictions outroc=mobilead_roc;
run;

proc logistic data=test_predictions plots=roc(id=prob);
 class publisher_id_class device_make_class device_os_class;
 logit: model install (event='1') = device_volume wifi resolution device_height 
 device_width publisher_id_class device_os_class device_make_class platform
 resolution*device_height resolution*device_width 
 resolution*resolution device_height*device_height device_width*device_width / nofit firth;
 roc pred=p_1;
run;

/* Question 1.3 - Threshold calculation - Cost(FP): $0.01, Cost(FN): $1 */
data mobilead_roc_cost;
 set mobilead_roc;
 False_positive_cost=0.01*_FALPOS_; 
 False_negative_cost=1*_FALNEG_;
 Total_cost=False_positive_cost+False_negative_cost;
run;
/* Threshold: 0.0077, Total Cost: $196.36 */

/* Part 2. Linear Probability Model */

/* Question 2.1 - Model Evolution */
/* Data import, Sampling */
data mobilead_lpm;
  set DIR.mobilead;
  
  /* One hot encoding for categorical variables */
  if device_platform_class = "android" then platform = 1; else platform = 0;
  
  if device_make_class = 1 then m1 = 1; else m1 = 0;
  if device_make_class = 2 then m2 = 1; else m2 = 0;
  if device_make_class = 3 then m3 = 1; else m3 = 0;
  if device_make_class = 4 then m4 = 1; else m4 = 0;
  if device_make_class = 5 then m5 = 1; else m5 = 0;
  if device_make_class = 6 then m6 = 1; else m6 = 0;
  if device_make_class = 7 then m7 = 1; else m7 = 0;
  if device_make_class = 8 then m8 = 1; else m8 = 0;
  if device_make_class = 9 then m9 = 1; else m9 = 0;
  
  if device_os_class = 1 then o1 = 1; else o1 = 0;
  if device_os_class = 2 then o2 = 1; else o2 = 0;
  if device_os_class = 3 then o3 = 1; else o3 = 0;
  if device_os_class = 4 then o4 = 1; else o4 = 0;
  if device_os_class = 5 then o5 = 1; else o5 = 0;
  if device_os_class = 6 then o6 = 1; else o6 = 0;
  if device_os_class = 7 then o7 = 1; else o7 = 0;
  if device_os_class = 8 then o8 = 1; else o8 = 0;
  if device_os_class = 9 then o9 = 1; else o9 = 0;
  
  if publisher_id_class = 1 then p1 = 1; else p1 = 0;
  if publisher_id_class = 2 then p2 = 1; else p2 = 0;
  if publisher_id_class = 3 then p3 = 1; else p3 = 0;
  if publisher_id_class = 4 then p4 = 1; else p4 = 0;
  if publisher_id_class = 5 then p5 = 1; else p5 = 0;
  if publisher_id_class = 6 then p6 = 1; else p6 = 0;
  if publisher_id_class = 7 then p7 = 1; else p7 = 0;
  if publisher_id_class = 8 then p8 = 1; else p8 = 0;
  if publisher_id_class = 9 then p9 = 1; else p9 = 0;
run;

proc surveyselect data=mobilead_lpm out=mobilead_lpm_sampled outall samprate=0.8 seed=10;
run;
data train_mobilead_lpm test_mobilead_lpm;
 set mobilead_lpm_sampled;
 if selected then output train_mobilead_lpm; 
 else output test_mobilead_lpm;
run;

/* Model 1: Adj-R2: 0.0016, R2-0.0016*/
proc reg data=train_mobilead_lpm;
 model install = p1 -- p9 o1 -- o9 m1 -- m9
 device_volume wifi resolution device_height 
 device_width platform ;
 title "Model 1: Using existing variables";
quit;

/* Model 2: Adj-R2: 0.0016, R2: 0.0020*/
data train_mobilead_lpm;
	set train_mobilead_lpm;	
	r_dh = resolution*device_height;
	r_dw = resolution*device_width;
	dh_dw = device_height*device_width;
run;

proc reg data=train_mobilead_lpm;
 model install = p1 -- p9 o1 -- o9 m1 -- m9
 device_volume wifi resolution device_height 
 device_width platform
 r_dh r_dw;
 title "Model 2: Using interaction terms";
quit;

/* Model 3: Adj-R2: 0.0018, R2: 0.0022 - BEST MODEL*/
data train_mobilead_lpm;
	set train_mobilead_lpm;	
	r2 = resolution*resolution;
	dh2 = device_height*device_height;
	dw2 = device_width*device_width;
run;

proc reg data=train_mobilead_lpm;
 model install = p1 -- p9 o1 -- o9 m1 -- m9
 device_volume wifi resolution device_height 
 device_width platform
 r_dh r_dw r2 dh2 dw2;
 title "Model 3: Using quadratic terms";
quit;

/* Model 4 - Heteroskedasticity removal - Adj-R2: 0.1398 - BEST MODEL */
proc reg data=train_mobilead_lpm;
 model install = p1 -- p9 o1 -- o9 m1 -- m9
 device_volume wifi resolution device_height 
 device_width platform
 r_dh r_dw r2 dh2 dw2 / hcc spec ;
 title 'Checking heteroskedasticity';  /* heteroskedasticity present */
quit;

data mobilead_lpm_sampled;
	set mobilead_lpm_sampled;	
	log_device_volume = log(device_volume);
	r_dh = resolution*device_height;
	r_dw = resolution*device_width;
	r2 = resolution*resolution;
	dh2 = device_height*device_height;
	dw2 = device_width*device_width;
	log_resolution = log(resolution);
	log_device_height = log(device_height);
run;

proc reg data=mobilead_lpm_sampled;
 linear: model install = p1 -- p9 o1 -- o9 m1 -- m9
 wifi log_resolution log_device_height / hcc spec ;
 weight log_device_volume selected;  /* selecting only train set (Selected) */
 title 'Model 4: Correcting heteroskedasticity';
quit;

/* Question 2.2 - ROC curve - AUC:0.4980  */
/* Make predictions for test observations */
proc reg data=mobilead_lpm_sampled;
 linear: model install = p1 -- p9 o1 -- o9 m1 -- m9
 wifi log_resolution log_device_height / hcc spec ;
 weight log_device_volume selected;
 output out=lpm_predictions_out p=lpm_predictions; /* predictions are made for all observations - training and test */
quit;

/* ROC - AUC:0.4980 - CI: (0.4633, 0.5327) */
proc logistic data=lpm_predictions_out plots=roc(id=prob);
 linear: model install = p1 -- p9 o1 -- o9 m1 -- m9
 wifi log_resolution log_device_height / nofit outroc=mobilead_lpm_roc;
 roc pred=lpm_predictions;
 where selected=0;
run;

/* Question 2.3 - Threshold calculation - Cost(FP): $0.01, Cost(FN): $1 */
/* SQL code */
/* 0.001 */ 
 proc sql;
 create table threshold as 
 select install, (case when lpm_predictions > 0.001 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

 proc sql;
 create table threshold001 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold;
 run;

/* 0.005 */
 proc sql;
 create table threshold2 as 
 select install, (case when lpm_predictions > 0.005 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold005 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold2;
 run;


 /*0.010 */
  proc sql;
 create table threshold3 as 
 select install, (case when lpm_predictions > 0.010 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold010 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold3;
 run;


 /*0.015 */
  proc sql;
 create table threshold4 as 
 select install, (case when lpm_predictions > 0.015 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold015 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold4;
 run;


 /* 0.020 */
  proc sql;
 create table threshold5 as 
 select install, (case when lpm_predictions > 0.020 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold020 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold5;
 run;


 /* 0.025 */
 proc sql;
 create table threshold6 as 
 select install, (case when lpm_predictions > 0.025 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold025 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold6;
 run;


 /* 0.030 */
 proc sql;
 create table threshold7 as 
 select install, (case when lpm_predictions > 0.030 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold030 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold7;
 run;
 

 /* 0.035 */
  proc sql;
 create table threshold8 as 
 select install, (case when lpm_predictions > 0.035 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold035 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold8;
 run;


 /* 0.040 */
  proc sql;
 create table threshold9 as 
 select install, (case when lpm_predictions > 0.040 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold040 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold9;
 run;


 /* 0.045 */
 proc sql;
 create table threshold10 as 
 select install, (case when lpm_predictions > 0.045 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold045 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold10;
 run;


 /* 0.050 */
  proc sql;
 create table threshold11 as 
 select install, (case when lpm_predictions > 0.050 then 1 else 0 end) as dummy from lpm_predictions_out;
 run;

  proc sql;
 create table threshold050 as
 select *, (case when install = 1 and dummy = 0 then 1 else 0 end)  as false_negatives,
 (case when install = 0 and dummy = 1 then 1 else 0 end)  as false_positives
 from threshold11;
 run;


proc sql;
create table test2 as 
select 0.001 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold001
union all
select 0.005 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold005
union all
select 0.010 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold010
union all
select 0.015 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold015
union all
select 0.020 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold020
union all
select 0.025 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold025
union all
select 0.030 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold030
union all
select 0.035 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold035
union all
select 0.040 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold040
union all
select 0.045 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold045
union all
select 0.050 as threshold, sum(false_positives) as False_Positives,
sum(False_Negatives) as False_Negatives
from threshold050
run;

/* Final table */
proc sql;
select *, 0.01 * False_Positives as FPCost,
False_Negatives as FNCost,
(0.01*False_Positives + 1*False_Negatives) as Total_Cost
from test2;
run;
  
 /*Average cost for Logistic regression model */
proc means data=mobilead_roc_cost;
 var Total_cost;
 run;
