---
title: "Predicting quality of weight lifting exercises based on wearable devices data" 
subtitle: "Final project for \"Pratical Machine Learning\" course by John Hopkins University"
author: "Matheus Cardoso"
date: "Jul 14, 2020"
output: 
  html_document: 
    fig_caption: yes
    fig_width: 10
    fig_height: 6
    highlight: zenburn
    keep_md: yes
    theme: simplex
    toc: yes
    number_sections: yes
    code_folding: hide
editor_options: 
  chunk_output_type: console
---


```r
knitr::opts_chunk$set(echo = TRUE, include = TRUE, cache = TRUE, warning = FALSE, message = FALSE)
```

# Abstract

In this project we'll be analysing the weight lifting exercises dataset provided by researchers at Pontifical Catholic University of Rio de Janeiro (PUC-Rio), Brazil.
Such an analysis is of importance to assess if a given person is doing the exercises correctly or not.
Our final aim is to create a machine learning based model to predict how well and which type of movements the person is doing.

# Methods

## Explaining the Data

Our entire analysis will be based on a datased cordially shared by researchers at PUC-Rio.
You can find the availabe data online in their [page](http://groupware.les.inf.puc-rio.br/har).
Bellow is their description about how they collected and proccessed the data.

><sub> This human activity recognition research has traditionally focused on discriminating between different activities, i.e. to predict "which" activity was performed at a specific point in time (like with the Daily Living Activities dataset above). The approach we propose for the Weight Lifting Exercises dataset is to investigate "how (well)" an activity was performed by the wearer. The "how (well)" investigation has only received little attention so far, even though it potentially provides useful information for a large variety of applications,such as sports training.
<br> In this work (see the paper) we first define quality of execution and investigate three aspects that pertain to qualitative activity recognition: the problem of specifying correct execution, the automatic and robust detection of execution mistakes, and how to provide feedback on the quality of execution to the user. We tried out an on-body sensing approach (dataset here), but also an "ambient sensing approach" (by using Microsoft Kinect - dataset still unavailable)
<br> Six young health participants were asked to perform one set of 10 repetitions of the Unilateral Dumbbell Biceps Curl in five different fashions: exactly according to the specification (Class A), throwing the elbows to the front (Class B), lifting the dumbbell only halfway (Class C), lowering the dumbbell only halfway (Class D) and throwing the hips to the front (Class E).
<br> Class A corresponds to the specified execution of the exercise, while the other 4 classes correspond to common mistakes. Participants were supervised by an experienced weight lifter to make sure the execution complied to the manner they were supposed to simulate. The exercises were performed by six male participants aged between 20-28 years, with little weight lifting experience. We made sure that all participants could easily simulate the mistakes in a safe and controlled manner by using a relatively light dumbbell (1.25kg).</sub>

## Processing Data

### Environment Setup

All the libraries we'll be using are downloaded in the beggining. 


```r
library(tidyverse)
library(magrittr)
library(tidymodels)
library(ranger)
library(patchwork)
```

### Getting Data

After the setup, we download the dataset.


```r
data_path          <- "./data"
df_training_file_path <- file.path(data_path, "training.csv")
df_testing_file_path  <- file.path(data_path, "testing.csv")
df_training_file_url  <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
df_testing_file_url   <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

if (!dir.exists(data_path)){
    dir.create(data_path)
}

if (!file.exists(df_training_file_path)){
    download.file(df_training_file_url, df_training_file_path, method = "curl")
}

if (!file.exists(df_testing_file_path)){
    download.file(df_testing_file_url, df_testing_file_path, method = "curl")
}
```

And load it to into memory.


```r
df_training <- read_csv(df_training_file_path)
df_testing <- read_csv(df_testing_file_path)
```

### Preprocess Dataset

In the current state, the data is quite messy, with several `NA` values and somewhat useless columns.
To handle this issue, we first figure out which collumns have `NA`s in it and remove them.
After, we manipulate the column containing date and time to extract more meaningthul information.


```r
df_training %>% 
    summarise(across(everything(), ~ all(sum(is.na(.x))) > 0)) %>% 
    select(where(isTRUE)) %>%
    colnames() -> columns_to_remove

df_training %<>% 
    select(!all_of(columns_to_remove) & !X1) %>%
    mutate(across(where(is.character), as.factor))

df_testing %<>% 
    select(!all_of(columns_to_remove) & !X1 & !problem_id) %>%
    mutate(across(where(is.character), as.factor))

df_training %<>% 
    mutate(
        cvtd_timestamp = as.character(cvtd_timestamp) %>% 
            strptime("%d/%m/%Y %H:%M")
    ) %>% 
    mutate(
        min = .$cvtd_timestamp$min,
        hour = .$cvtd_timestamp$hour,
        mday = .$cvtd_timestamp$mday,
        mon = .$cvtd_timestamp$mon,
        wday = .$cvtd_timestamp$wday
    ) %>% 
    mutate(
        cvtd_timestamp = as.character(cvtd_timestamp)
    )

df_testing %<>% 
    mutate(
        cvtd_timestamp = as.character(cvtd_timestamp) %>% 
            strptime("%d/%m/%Y %H:%M")
    ) %>% 
    mutate(
        min = .$cvtd_timestamp$min,
        hour = .$cvtd_timestamp$hour,
        mday = .$cvtd_timestamp$mday,
        mon = .$cvtd_timestamp$mon,
        wday = .$cvtd_timestamp$wday
    ) %>% 
    mutate(
        cvtd_timestamp = factor(as.character(cvtd_timestamp))
    )
```


## Creating the Model

Now that we have our data in a more tidy format, we start to build the model.

We'll going to create a Random Forest model, since this was the best model I could build.
I created 5 models: SVM, Simple Neural Network (5 layers), Logistic Regression and Random Forest.
By far the best model was Random Forest.
I opted to exclue the other inferior models from this report due to the limit of 2000 words in the document. (Rule imposed by the professor at project page.)

### Separate Training and Testing sets

To assess the accuracy of the model we'll need some sort of "neutral" or "unseen" data to run our model on.
For this reason, we start spliting our tidy data into train and test sets.
I opted to split the dataframe with a proportion of 80% going to training set and the remaining 20% to the test set.

One important thing to note is that the `classe` variable, our outcome variable, is not evenly distributed among its levels. 
for this reason, we specify `strata = classe` in the `initial_split()` function.

We also add some more processing steps in the `recipe()` function, in order to remove highly correlated columns and columns with near zero variance. Doing so, we speed up the time to train the model.


```r
set.seed(42)
data_split <- initial_split(df_training, strata = classe, prop = 0.8)

data_train <- training(data_split)
data_test  <- testing(data_split)

data_recipe <-
    recipe(classe ~ ., data = data_train) %>% 
    step_rm(cvtd_timestamp) %>% 
    step_normalize(all_numeric(), -all_outcomes()) %>% 
    step_corr(all_numeric(), -all_outcomes()) %>% 
    step_nzv(all_numeric(), -all_outcomes()) %>% 
    step_zv(all_numeric(), -all_outcomes()) %>% 
    step_dummy(all_nominal(), -all_outcomes(), one_hot = TRUE)

data_prep <- prep(data_recipe)

data_juice <- juice(data_prep)
```

### Create 10-fold Cross Validation

Although we separated the data into train and test sets, we would like to go even further and use cross validation.
Using this aproach we can estimate the prediction error in out-of-sample data.


```r
set.seed(42)
folds <-
    vfold_cv(data_train, v = 10, strata = classe)
```

### Building the Random Forest Model

Now, with the data finally processed and the cross validation sets specified, we can create the Random Forest model.

I choose to use 1000 trees and tune the `mtry` and `min_n` parameters.


```r
rf_mod <-
    rand_forest(trees = 1000, mtry = tune(), min_n = tune()) %>%
    set_engine("ranger", num.threads = parallel::detectCores()) %>%
    set_mode("classification")

rf_wf <-
    workflow() %>%
    add_recipe(data_recipe) %>% 
    add_model(rf_mod)

# modelling data take a huge amount of time.
# we'd like to prevent running this every session,
# so we store the trained model in the first run
# and use it in later moments if rerunning the code.
path_rf_tune <- "./data/rf_tune.rds"
if (! file.exists(path_rf_tune)) {
    set.seed(42)
    rf_tune <-
        tune_grid(
            rf_wf,
            resamples = folds,
            grid = 5)
    write_rds(rf_tune, path_rf_tune)
} else {
    rf_tune <- read_rds(path_rf_tune)
}
```

Analysing the tuned model, we can see the following:


```r
p_rf_ac_mtry <- 
rf_tune %>%
    collect_metrics() %>%
    filter(.metric == "accuracy") %>%
    ggplot(aes(mtry, mean)) + geom_point() + geom_line() +
    labs(
        title = "Accuracy of Random Forest",
        subtitle = "By number randomly sampled predictors",
        x = "No. randomly sampled predictors",
        y = "Accuracy") +
    theme(axis.text.y = element_text(angle = 45))

p_rf_ac_min_n <- 
rf_tune %>%
    collect_metrics() %>%
    filter(.metric == "accuracy") %>%
    ggplot(aes(min_n, mean)) + geom_point() + geom_line() +
    labs(
        title = "Accuracy of Random Forest",
        subtitle = "By minimum number of data poins in\na node required for the node to be split further",
        x = "Minimum number of data points in\na node that are required for the node to be split further.",
        y = "Accuracy") +
    theme(axis.text.y = element_text(angle = 45))

p_rf_auc_mtry <- 
rf_tune %>%
    collect_metrics() %>%
    filter(.metric == "roc_auc") %>%
    ggplot(aes(mtry, mean)) + geom_point() + geom_line() +
    labs(
        title = "Area under the curve of Random Forest",
        subtitle = "By number randomly sampled predictors",
        x = "No. randomly sampled predictors",
        y = "Area under the curve") +
    theme(axis.text.y = element_text(angle = 45))

p_rf_auc_min_n <- 
rf_tune %>%
    collect_metrics() %>%
    filter(.metric == "roc_auc") %>%
    ggplot(aes(min_n, mean)) + geom_point() + geom_line() +
    labs(
        title = "Area under the curve of Random Forest",
        subtitle = "By minimum number of data poins in\na node required for the node to be split further",
        x = "Minimum number of data points in\na node that are required for the node to be split further.",
        y = "Area under the curve") +
    theme(axis.text.y = element_text(angle = 45))

# this creates a nice combination of plots
(p_rf_ac_mtry / p_rf_ac_min_n) | (p_rf_auc_mtry / p_rf_auc_min_n)
```

![](tidymodels_project_files/figure-html/tuned_model-1.png)<!-- -->

```r
rf_tune %>% 
    collect_metrics() %>% 
    select(-n, -.estimator) %>% 
    arrange(.metric, -mean, -std_err) %>% 
    knitr::kable(caption = "Result of the 5 Random Forest models")
```



Table: Result of the 5 Random Forest models

 mtry   min_n  .metric          mean     std_err
-----  ------  ---------  ----------  ----------
   32       5  accuracy    0.9993631   0.0002122
   14      25  accuracy    0.9991084   0.0002165
   40      24  accuracy    0.9990447   0.0001957
   52      34  accuracy    0.9985990   0.0002474
    4      17  accuracy    0.9967514   0.0004789
   32       5  roc_auc     0.9999948   0.0000024
   14      25  roc_auc     0.9999929   0.0000030
   40      24  roc_auc     0.9999878   0.0000066
    4      17  roc_auc     0.9999815   0.0000047
   52      34  roc_auc     0.9999765   0.0000122

As we can see, the model with `mtry = 32` and `min_n = 5` achieved the best prediction result.
Therefore, this will the the final parameters we'll use to build the model.


```r
rf_tune_best <- 
    rf_tune %>% 
    select_best("accuracy")

rf_mod_final <- finalize_model(rf_mod, rf_tune_best)

rf_wf_final <- 
    workflow() %>% 
    add_recipe(data_recipe) %>% 
    add_model(rf_mod_final)
    
# same idea here. cache the results.
path_rf_fit <- "./data/rf_fit.rds"
if (! file.exists(path_rf_fit)) {
    set.seed(42)
    rf_fit <- 
        rf_wf_final %>% 
        last_fit(data_split)
    write_rds(rf_fit, path_rf_fit)
} else {
    rf_fit <- read_rds(path_rf_fit)
}
```

# Results

Now that we have built the final model and trained it, we can assess the results for the model's predictions.


```r
rf_fit %>% 
    collect_metrics() %>% 
    knitr::kable(caption = "Final Model Metrics")
```



Table: Final Model Metrics

.metric    .estimator    .estimate
---------  -----------  ----------
accuracy   multiclass    0.9982152
roc_auc    hand_till     0.9999957

As we expected, the accuracy and area under the curve of the final model is very close to the estimations made based on cross validation models.

Below I show how well the model perform in the test set.


```r
p_rf_auc <- 
rf_fit %>% 
    collect_predictions() %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot() +
    labs(
        title = "Area Under the Curve for Random Forest Model",
        subtitle = "As both plots show, this is a nearly perfect model for this data.")

p_rf_gc <- 
rf_fit %>% 
    collect_predictions() %>% 
    gain_curve(classe, .pred_A:.pred_E) %>% 
    autoplot() +
    labs(title = "Gain Curve for Random Forest Model")

(p_rf_auc | p_rf_gc)
```

![](tidymodels_project_files/figure-html/assess_general_performance-1.png)<!-- -->

```r
p_rf_heat <- 
rf_fit %>% 
    collect_predictions() %>% 
    conf_mat(.pred_class, classe) %>% 
    autoplot(type = "heatmap") + 
    labs(title = "Confusion Matrix for Random Forest Model")

p_rf_heat
```

![](tidymodels_project_files/figure-html/assess_general_performance-2.png)<!-- -->


# Conclusion

So, based on this results, we can state that using a Random Forest model we can successfully predict new data with an accuracy of 99.8%.
