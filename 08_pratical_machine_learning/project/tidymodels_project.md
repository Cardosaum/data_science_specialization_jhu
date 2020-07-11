---
title: "Predicting quality of weight lifting exercises based on wearable devices data" 
subtitle: "Final project for \"Pratical Machine Learning\" course by John Hopkins University"
author: "Matheus Cardoso"
date: "Jul 07, 2020"
output: 
  html_document: 
    fig_caption: yes
    highlight: zenburn
    keep_md: yes
    theme: simplex
    toc: yes
    number_sections: yes
    code_folding: hide
editor_options: 
  chunk_output_type: console
---



# Abstract

In this project I'll analyze data about Human Active Recognition (HAR).


# Methods

## Getting Data


```r
library(tidyverse)
library(magrittr)
library(tidymodels)
library(ranger)
library(patchwork)
```


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


```r
df_training <- read_csv(df_training_file_path)
df_testing <- read_csv(df_testing_file_path)

# skimr::skim(df_training)
# skimr::skim(df_testing)
```


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


```r
set.seed(42)
data_split <- initial_split(df_training, strata = classe, prop = 0.8)
data_split
```

```
## <Analysis/Assess/Total>
## <15700/3922/19622>
```

```r
data_split %>% 
    training %>% 
    glimpse()
```

```
## Rows: 15,700
## Columns: 64
## $ user_name            <fct> carlitos, carlitos, carlitos, carlitos, carlitos…
## $ raw_timestamp_part_1 <dbl> 1323084231, 1323084231, 1323084232, 1323084232, …
## $ raw_timestamp_part_2 <dbl> 788290, 820366, 120339, 196328, 304277, 368296, …
## $ cvtd_timestamp       <chr> "2011-12-05 11:23:00", "2011-12-05 11:23:00", "2…
## $ new_window           <fct> no, no, no, no, no, no, no, no, no, no, no, no, …
## $ num_window           <dbl> 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, …
## $ roll_belt            <dbl> 1.41, 1.42, 1.48, 1.48, 1.45, 1.42, 1.43, 1.45, …
## $ pitch_belt           <dbl> 8.07, 8.07, 8.05, 8.07, 8.06, 8.09, 8.16, 8.18, …
## $ yaw_belt             <dbl> -94.4, -94.4, -94.4, -94.4, -94.4, -94.4, -94.4,…
## $ total_accel_belt     <dbl> 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
## $ gyros_belt_x         <dbl> 0.00, 0.00, 0.02, 0.02, 0.02, 0.02, 0.02, 0.03, …
## $ gyros_belt_y         <dbl> 0.00, 0.00, 0.00, 0.02, 0.00, 0.00, 0.00, 0.00, …
## $ gyros_belt_z         <dbl> -0.02, -0.02, -0.03, -0.02, -0.02, -0.02, -0.02,…
## $ accel_belt_x         <dbl> -21, -20, -22, -21, -21, -22, -20, -21, -22, -22…
## $ accel_belt_y         <dbl> 4, 5, 3, 2, 4, 3, 2, 2, 2, 4, 4, 2, 4, 5, 5, 1, …
## $ accel_belt_z         <dbl> 22, 23, 21, 24, 21, 21, 24, 23, 23, 21, 21, 22, …
## $ magnet_belt_x        <dbl> -3, -2, -6, -6, 0, -4, 1, -5, -2, -3, -8, -1, -6…
## $ magnet_belt_y        <dbl> 599, 600, 604, 600, 603, 599, 602, 596, 602, 606…
## $ magnet_belt_z        <dbl> -313, -305, -310, -302, -312, -311, -312, -317, …
## $ roll_arm             <dbl> -128, -128, -128, -128, -128, -128, -128, -128, …
## $ pitch_arm            <dbl> 22.5, 22.5, 22.1, 22.1, 22.0, 21.9, 21.7, 21.5, …
## $ yaw_arm              <dbl> -161, -161, -161, -161, -161, -161, -161, -161, …
## $ total_accel_arm      <dbl> 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, …
## $ gyros_arm_x          <dbl> 0.00, 0.02, 0.02, 0.00, 0.02, 0.00, 0.02, 0.02, …
## $ gyros_arm_y          <dbl> 0.00, -0.02, -0.03, -0.03, -0.03, -0.03, -0.03, …
## $ gyros_arm_z          <dbl> -0.02, -0.02, 0.02, 0.00, 0.00, 0.00, -0.02, 0.0…
## $ accel_arm_x          <dbl> -288, -289, -289, -289, -289, -289, -288, -290, …
## $ accel_arm_y          <dbl> 109, 110, 111, 111, 111, 111, 109, 110, 111, 111…
## $ accel_arm_z          <dbl> -123, -126, -123, -123, -122, -125, -122, -123, …
## $ magnet_arm_x         <dbl> -368, -368, -372, -374, -369, -373, -369, -366, …
## $ magnet_arm_y         <dbl> 337, 344, 344, 337, 342, 336, 341, 339, 343, 338…
## $ magnet_arm_z         <dbl> 516, 513, 512, 506, 513, 509, 518, 509, 520, 509…
## $ roll_dumbbell        <dbl> 13.05217, 12.85075, 13.43120, 13.37872, 13.38246…
## $ pitch_dumbbell       <dbl> -70.49400, -70.27812, -70.39379, -70.42856, -70.…
## $ yaw_dumbbell         <dbl> -84.87394, -85.14078, -84.87363, -84.85306, -84.…
## $ total_accel_dumbbell <dbl> 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, …
## $ gyros_dumbbell_x     <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, …
## $ gyros_dumbbell_y     <dbl> -0.02, -0.02, -0.02, -0.02, -0.02, -0.02, -0.02,…
## $ gyros_dumbbell_z     <dbl> 0.00, 0.00, -0.02, 0.00, 0.00, 0.00, 0.00, 0.00,…
## $ accel_dumbbell_x     <dbl> -234, -232, -232, -233, -234, -232, -232, -233, …
## $ accel_dumbbell_y     <dbl> 47, 46, 48, 48, 48, 47, 47, 47, 47, 48, 48, 47, …
## $ accel_dumbbell_z     <dbl> -271, -270, -269, -270, -269, -270, -269, -269, …
## $ magnet_dumbbell_x    <dbl> -559, -561, -552, -554, -558, -551, -549, -564, …
## $ magnet_dumbbell_y    <dbl> 293, 298, 303, 292, 294, 295, 292, 299, 291, 302…
## $ magnet_dumbbell_z    <dbl> -65, -63, -60, -68, -66, -70, -65, -64, -65, -69…
## $ roll_forearm         <dbl> 28.4, 28.3, 28.1, 28.0, 27.9, 27.9, 27.7, 27.6, …
## $ pitch_forearm        <dbl> -63.9, -63.9, -63.9, -63.9, -63.9, -63.9, -63.8,…
## $ yaw_forearm          <dbl> -153, -152, -152, -152, -152, -152, -152, -152, …
## $ total_accel_forearm  <dbl> 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, …
## $ gyros_forearm_x      <dbl> 0.03, 0.03, 0.02, 0.02, 0.02, 0.02, 0.03, 0.02, …
## $ gyros_forearm_y      <dbl> 0.00, -0.02, -0.02, 0.00, -0.02, 0.00, 0.00, -0.…
## $ gyros_forearm_z      <dbl> -0.02, 0.00, 0.00, -0.02, -0.03, -0.02, -0.02, -…
## $ accel_forearm_x      <dbl> 192, 196, 189, 189, 193, 195, 193, 193, 191, 193…
## $ accel_forearm_y      <dbl> 203, 204, 206, 206, 203, 205, 204, 205, 203, 205…
## $ accel_forearm_z      <dbl> -215, -213, -214, -214, -215, -215, -214, -214, …
## $ magnet_forearm_x     <dbl> -17, -18, -16, -17, -9, -18, -16, -17, -11, -15,…
## $ magnet_forearm_y     <dbl> 654, 658, 658, 655, 660, 659, 653, 657, 657, 655…
## $ magnet_forearm_z     <dbl> 476, 469, 469, 473, 478, 470, 476, 465, 478, 472…
## $ classe               <fct> A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, …
## $ min                  <int> 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, …
## $ hour                 <int> 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, …
## $ mday                 <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
## $ mon                  <int> 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, …
## $ wday                 <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

```r
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

data_prep
```

```
## Data Recipe
## 
## Inputs:
## 
##       role #variables
##    outcome          1
##  predictor         63
## 
## Training data contained 15700 data points and no missing data.
## 
## Operations:
## 
## Variables removed cvtd_timestamp [trained]
## Centering and scaling for raw_timestamp_part_1, ... [trained]
## Correlation filter removed accel_belt_x, accel_belt_y, ... [trained]
## Sparse, unbalanced variable filter removed no terms [trained]
## Zero variance filter removed no terms [trained]
## Dummy variables from user_name, new_window [trained]
```

```r
data_juice <- juice(data_prep)
```

## create 10-fold cross validation


```r
set.seed(42)
folds <-
    vfold_cv(data_train, v = 10, strata = classe)
```

## random forest


```r
rf_mod <-
    rand_forest(trees = tune(), mtry = tune(), min_n = tune()) %>%
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

rf_tune %>% 
    autoplot(metric = "accuracy")
```

![](tidymodels_project_files/figure-html/model_random_forest-1.png)<!-- -->

```r
rf_tune %>% 
    autoplot(metric = "roc_auc")
```

![](tidymodels_project_files/figure-html/model_random_forest-2.png)<!-- -->

```r
rf_tune_best <- 
    rf_tune %>% 
    select_best("accuracy")

rf_mod_final <- finalize_model(rf_mod, rf_tune_best)

rf_wf_final <- 
    workflow() %>% 
    add_recipe(data_recipe) %>% 
    add_model(rf_mod_final)
    
rf_wf_final    
```

```
## ══ Workflow ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
## Preprocessor: Recipe
## Model: rand_forest()
## 
## ── Preprocessor ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
## 6 Recipe Steps
## 
## ● step_rm()
## ● step_normalize()
## ● step_corr()
## ● step_nzv()
## ● step_zv()
## ● step_dummy()
## 
## ── Model ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
## Random Forest Model Specification (classification)
## 
## Main Arguments:
##   mtry = 32
##   trees = tune()
##   min_n = 5
## 
## Engine-Specific Arguments:
##   num.threads = parallel::detectCores()
## 
## Computational engine: ranger
```

```r
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
    
rf_fit %>% 
    collect_metrics()
```

```
## # A tibble: 2 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy multiclass     0.998
## 2 roc_auc  hand_till      1.00
```

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

![](tidymodels_project_files/figure-html/model_random_forest-3.png)<!-- -->

```r
p_rf_heat <- 
rf_fit %>% 
    collect_predictions() %>% 
    conf_mat(.pred_class, classe) %>% 
    autoplot(type = "heatmap") + 
    labs(title = "Confusion Matrix for Random Forest Model")

p_rf_heat
```

![](tidymodels_project_files/figure-html/model_random_forest-4.png)<!-- -->

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

![](tidymodels_project_files/figure-html/model_random_forest-5.png)<!-- -->



<!-- ## SVM -->

<!-- ```{r model_random_forest} -->
<!-- svm_mod <-  -->
<!--     svm_poly(cost = tune(), degree = tune(), scale_factor = tune()) %>%  -->
<!--     set_engine("kernlab") %>%  -->
<!--     set_mode("classification") -->

<!-- svm_wf <- -->
<!--     workflow() %>% -->
<!--     add_recipe(data_recipe) %>%  -->
<!--     add_model(svm_mod) -->

<!-- # modelling data take a huge amount of time. -->
<!-- # we'd like to prevent running this every session, -->
<!-- # so we store the trained model in the first run -->
<!-- # and use it in later moments if rerunning the code. -->
<!-- path_svm_tune <- "./data/svm_tune.rds" -->
<!-- if (! file.exists(path_svm_tune)) { -->
<!--     set.seed(42) -->
<!--     svm_tune <- -->
<!--         tune_grid( -->
<!--             svm_wf, -->
<!--             resamples = folds, -->
<!--             grid = 5) -->
<!--     write_rds(svm_tune, path_svm_tune) -->
<!-- } else { -->
<!--     svm_tune <- read_rds(path_svm_tune) -->
<!-- } -->

<!-- svm_tune %>%  -->
<!--     collect_metrics() -->

<!-- svm_tune %>%  -->
<!--     autoplot(metric = "accuracy") -->

<!-- svm_tune %>%  -->
<!--     autoplot(metric = "roc_auc") -->

<!-- svm_tune_best <-  -->
<!--     svm_tune %>%  -->
<!--     select_best("accuracy") -->

<!-- svm_mod_final <- finalize_model(svm_mod, svm_tune_best) -->

<!-- svm_wf_final <-  -->
<!--     workflow() %>%  -->
<!--     add_recipe(data_recipe) %>%  -->
<!--     add_model(svm_mod_final) -->

<!-- svm_wf_final     -->

<!-- # same idea here. cache the results. -->
<!-- path_svm_fit <- "./data/svm_fit.rds" -->
<!-- if (! file.exists(path_svm_fit)) { -->
<!--     set.seed(42) -->
<!--     svm_fit <-  -->
<!--         svm_wf_final %>%  -->
<!--         last_fit(data_split) -->
<!--     write_rds(svm_fit, path_svm_fit) -->
<!-- } else { -->
<!--     svm_fit <- read_rds(path_svm_fit) -->
<!-- } -->

<!-- svm_fit %>%  -->
<!--     collect_metrics() -->

<!-- svm_fit %>%  -->
<!--     collect_predictions() %>%  -->
<!--     roc_curve(classe, .pred_A:.pred_E) %>%  -->
<!--     autoplot() -->

<!-- svm_fit %>%  -->
<!--     collect_predictions() %>%  -->
<!--     gain_curve(classe, .pred_A:.pred_E) %>%  -->
<!--     autoplot() -->
<!-- ``` -->


<!-- ```{r rf_trash, include=FALSE} -->
<!-- # rf_tune %>%  -->
<!-- #     collect_metrics() %>%  -->
<!-- #     filter(.metric == "accuracy") %>%  -->
<!-- #     ggplot(aes(mtry, std_err)) + geom_point() + geom_line() + -->
<!-- #     facet_grid(.metric ~ .) + -->
<!-- #     labs( -->
<!-- #         title = "Standard Error in Accuracy of Random Forest", -->
<!-- #         subtitle = "By number randomly sampled predictors", -->
<!-- #         x = "No. randomly sampled predictors", -->
<!-- #         y = "Standard Error") -->
<!-- #      -->
<!-- # rf_tune %>%  -->
<!-- #     collect_metrics() %>%  -->
<!-- #     filter(.metric == "roc_auc") %>%  -->
<!-- #     ggplot(aes(mtry, std_err)) + geom_point() + geom_line() + -->
<!-- #     facet_grid(.metric ~ .) + -->
<!-- #     labs( -->
<!-- #         title = "Standard Error of Random Forest", -->
<!-- #         subtitle = "By number randomly sampled predictors", -->
<!-- #         x = "No. randomly sampled predictors", -->
<!-- #         y = "Standard Error") -->
<!-- #      -->
<!-- #      -->
<!-- # rf_tune %>%  -->
<!-- #     collect_metrics() %>%  -->
<!-- #     filter(.metric == "accuracy") %>%  -->
<!-- #     ggplot(aes(min_n, std_err)) + geom_point() + geom_line() + -->
<!-- #     facet_grid(.metric ~ .)  -->
<!-- #      -->
<!-- # rf_tune %>%  -->
<!-- #     collect_metrics() %>%  -->
<!-- #     filter(.metric == "roc_auc") %>%  -->
<!-- #     ggplot(aes(min_n, std_err)) + geom_point() + geom_line() + -->
<!-- #     facet_grid(.metric ~ .) + -->
<!-- #     labs( -->
<!-- #         title = "Standard Error of Random Forest", -->
<!-- #         subtitle = "By minimum number of data poins in a node required for the node to be split further", -->
<!-- #         x = "Minimum number of data points in a node that are required for the node to be split further.", -->
<!-- #         y = "Standard Error") -->
<!-- #      -->
<!-- #      -->

<!-- rf_tune %>% collect_metrics() -->

<!-- ``` -->

<!-- ## Other -->

<!-- ```{r} -->
<!-- library(nnet) -->
<!-- set.seed(42) -->
<!-- model_nn <-  -->
<!--     mlp() %>%  -->
<!--     set_engine("nnet") %>%  -->
<!--     set_mode("classification") %>%  -->
<!--     fit(classe ~ ., data = data_training) -->

<!-- model_nn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     gain_curve(classe, .pred_A:.pred_E) %>% -->
<!--     autoplot() -->

<!-- model_nn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     roc_curve(classe, .pred_A:.pred_E) %>%  -->
<!--     autoplot() -->

<!-- model_nn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(predict(model_nn, data_testing)) %>%  -->
<!--     bind_cols(select(data_testing, classe)) %>%  -->
<!--     metrics(classe, .pred_A:.pred_E, estimate = .pred_class) -->


<!-- ``` -->


<!-- ```{r} -->
<!-- library(kknn) -->
<!-- set.seed(42) -->
<!-- model_kknn <-  -->
<!--     nearest_neighbor() %>%  -->
<!--     set_engine("kknn") %>%  -->
<!--     set_mode("classification") %>%  -->
<!--     fit(classe ~ ., data = data_training) -->

<!-- model_kknn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     gain_curve(classe, .pred_A:.pred_E) %>% -->
<!--     autoplot() -->

<!-- model_kknn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     roc_curve(classe, .pred_A:.pred_E) %>%  -->
<!--     autoplot() -->

<!-- model_kknn %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(predict(model_kknn, data_testing)) %>%  -->
<!--     bind_cols(select(data_testing, classe)) %>%  -->
<!--     metrics(classe, .pred_A:.pred_E, estimate = .pred_class) -->


<!-- ``` -->

<!-- ```{r} -->
<!-- set.seed(42) -->
<!-- model_mr <-  -->
<!--     multinom_reg() %>%  -->
<!--     set_engine("nnet") %>%  -->
<!--     set_mode("classification") %>%  -->
<!--     fit(classe ~ ., data = data_training) -->

<!-- model_mr %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     gain_curve(classe, .pred_A:.pred_E) %>% -->
<!--     autoplot() -->

<!-- model_mr %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(data_testing) %>%  -->
<!--     roc_curve(classe, .pred_A:.pred_E) %>%  -->
<!--     autoplot() -->

<!-- model_mr %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(predict(model_mr, data_testing)) %>%  -->
<!--     bind_cols(select(data_testing, classe)) %>%  -->
<!--     metrics(classe, .pred_A:.pred_E, estimate = .pred_class) -->

<!-- model_mr %>%  -->
<!--     predict(data_testing, type = "prob") %>%  -->
<!--     bind_cols(predict(model_mr, data_testing)) %>%  -->
<!--     bind_cols(select(data_testing, classe)) %>%  -->
<!--     glimpse() -->
<!-- ``` -->

<!-- ```{r} -->
<!-- set.seed(1) -->
<!-- val_set <-  -->
<!--     validation_split(training, -->
<!--                      strata = classe, -->
<!--                      prop = 0.80) -->

<!-- lr_mod <-  -->
<!--     logistic_reg(penalty = tune(), mixture = 1) %>%  -->
<!--     set_engine("glmnet", family = "multinomial") -->

<!-- lr_recipe <-  -->
<!--     recipe(classe ~ ., data = training) %>%  -->
<!--     step_dummy(all_nominal(), -all_outcomes()) %>%  -->
<!--     step_zv(all_predictors()) %>%  -->
<!--     step_normalize(all_predictors()) -->

<!-- lr_workflow <-  -->
<!--     workflow() %>%  -->
<!--     add_model(lr_mod) %>%  -->
<!--     add_recipe(lr_recipe) -->

<!-- lr_reg_grid <- tibble(penalty = 10 ^ seq(-4, -1, length.out = 30)) -->

<!-- lr_res <-  -->
<!--     lr_workflow %>%  -->
<!--     tune_grid(val_set, -->
<!--               grid = lr_reg_grid, -->
<!--               control = control_grid(save_pred = TRUE), -->
<!--               metrics = metric_set(roc_auc)) -->

<!-- lr_plot <- -->
<!--     lr_res %>%  -->
<!--     collect_metrics() %>%  -->
<!--     ggplot(aes(penalty, mean)) + -->
<!--         geom_point() + -->
<!--         geom_line() + -->
<!--         ylab("Area under the ROC curve") + -->
<!--         scale_x_log10(labels = scales::label_number()) -->

<!-- lr_plot -->
<!-- ``` -->


<!-- ```{r} -->
<!-- df_split <- initial_split(training, strata = classe) -->

<!-- df_train <- training(df_split) -->
<!-- df_test  <- testing(df_split) -->

<!-- nrow(df_train)/nrow(training) -->

<!-- df_train %>%  -->
<!--     count(classe) %>%  -->
<!--     mutate(prop = n/sum(n)) -->

<!-- df_test %>%  -->
<!--     count(classe) %>%  -->
<!--     mutate(prop = n/sum(n)) -->
<!-- ``` -->

<!-- ```{r} -->
<!-- rf_mod <-  -->
<!--     rand_forest(trees = 1000) %>%  -->
<!--     set_engine("ranger", num.threads = parallel::detectCores()) %>%  -->
<!--     set_mode("classification") -->

<!-- data_recipe <-  -->
<!--     recipe(classe ~ ., data = training) %>%  -->
<!--     step_rm(cvtd_timestamp) %>%  -->
<!--     step_dummy(all_nominal(), -all_outcomes()) %>%  -->
<!--     step_zv(all_predictors()) -->

<!-- rf_fit <-  -->
<!--     rf_mod %>%  -->
<!--     fit(classe ~ ., data = df_train) -->

<!-- rf_fit -->
<!-- ``` -->

<!-- ```{r} -->
<!-- rf_training_pred <-  -->
<!--     predict(rf_fit, df_train) %>%  -->
<!--     bind_cols(predict(rf_fit, df_train, type = "prob")) %>%  -->
<!--     bind_cols(df_train %>%  -->
<!--                   select(classe)) -->
<!-- ``` -->

<!-- ```{r} -->
<!-- rf_training_pred %>%  -->
<!--     roc_auc(truth = classe, .pred_A, .pred_B, .pred_C, .pred_D, .pred_E) -->

<!-- rf_training_pred %>%  -->
<!--     accuracy(truth = classe, .pred_class) -->
<!-- ``` -->

<!-- ```{r} -->
<!-- rf_testing_pred <-  -->
<!--     predict(rf_fit, df_test) %>%  -->
<!--     bind_cols(predict(rf_fit, df_test, type = "prob")) %>%  -->
<!--     bind_cols(df_test %>% select(classe)) -->
<!-- ``` -->

<!-- ```{r} -->
<!-- rf_testing_pred %>%  -->
<!--     roc_auc(truth = classe, .pred_A, .pred_B, .pred_C, .pred_D, .pred_E) -->

<!-- rf_testing_pred %>%  -->
<!--     accuracy(truth = classe, .pred_class) -->

<!-- rf_testing_pred %>%  -->
<!--     roc_curve(truth = classe, .pred_A, .pred_B, .pred_C, .pred_D, .pred_E) %>%  -->
<!--     autoplot() -->
<!-- ``` -->

<!-- ```{r} -->
<!-- library(Rtsne) -->
<!-- set.seed(42) -->

<!-- iris_unique <- unique(iris) -->
<!-- tsne_out <- Rtsne( -->
<!--     as.matrix(iris_unique[, 1:4]), -->
<!--     perplexity = 30, -->
<!--     dims = 3, -->
<!--     theta = 0.0, -->
<!--     pca = T, -->
<!--     max_iter = 1E3, -->
<!--     pca_scale = T, -->
<!--     verbose = T, -->
<!--     eta = 200.0, -->
<!--     num_threads = parallel::detectCores()) -->

<!-- plot(tsne_out$Y, col = iris_unique$Species, asp = 1) -->

<!-- library(plotly) -->
<!-- plot_ly( -->
<!--     x = tsne_out$Y[, 1], -->
<!--     y = tsne_out$Y[, 2], -->
<!--     z = tsne_out$Y[, 3], -->
<!--     type = "scatter3d", -->
<!--     mode = "markers", -->
<!--     color = iris_unique$Species -->
<!-- ) -->
<!-- ``` -->

<!-- ```{r} -->
<!-- library(Rtsne) -->
<!-- set.seed(42) -->
<!-- training %>%  -->
<!--     # filter(classe == "A" | classe == "D") %>%  -->
<!--     # slice_sample(n = 500) %>%  -->
<!--     select(where(is.numeric)) -> df -->

<!-- training %>%  -->
<!--     # filter(classe == "A" | classe == "D") %>%  -->
<!--     # slice_sample(n = 500) %>%  -->
<!--     .$classe %>%  -->
<!--     as.factor() -> df_color -->

<!-- tsne_train <- -->
<!--     Rtsne( -->
<!--         df, -->
<!--         perplexity = 30, -->
<!--         dims = 3, -->
<!--         theta = 0.5, -->
<!--         pca = T, -->
<!--         max_iter = 3E3, -->
<!--         pca_scale = T, -->
<!--         verbose = T, -->
<!--         eta = 200.0, -->
<!--         num_threads = parallel::detectCores() - 2) -->



<!-- a <- tsne_train$Y %>% as_tibble() -->

<!-- ggplot(a, aes(V1, V2, color = df_color)) + -->
<!--     geom_point() -->
<!-- ``` -->

<!-- ```{r} -->
<!-- library(plotly) -->

<!-- plot_ly( -->
<!--     x = a$V1, -->
<!--     y = a$V2, -->
<!--     z = a$V3, -->
<!--     type = "scatter3d", -->
<!--     mode = "markers", -->
<!--     color = df_color -->
<!-- ) -->
<!-- ``` -->

