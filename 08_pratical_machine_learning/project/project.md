---
title: "Final Project - Pratical Machine Learning" 
subtitle: "Analising and modeling Human Active Recognition data"
author: "Matheus Cardoso"
date: "May 28, 2020"
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
# df_training %>% 
#     summarise(across(everything(), ~ sum(is.na(.x)))) %>% 
#     skimr::skim()

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
data_recipe <-
    training(data_split) %>% 
    recipe(classe ~ .) %>% 
    step_corr(all_numeric()) %>% 
    step_center(all_numeric(), -all_outcomes()) %>% 
    step_scale(all_numeric(), -all_outcomes()) %>% 
    prep()


data_training <- 
    juice(data_recipe)

data_training %>% 
    glimpse()
```

```
## Rows: 15,700
## Columns: 58
## $ user_name            <fct> carlitos, carlitos, carlitos, carlitos, carlitos…
## $ raw_timestamp_part_1 <dbl> 1.255076, 1.255076, 1.255081, 1.255081, 1.255081…
## $ raw_timestamp_part_2 <dbl> 0.996776942, 1.108480663, -1.329342645, -1.06471…
## $ cvtd_timestamp       <fct> 2011-12-05 11:23:00, 2011-12-05 11:23:00, 2011-1…
## $ new_window           <fct> no, no, no, no, no, no, no, no, no, no, no, no, …
## $ num_window           <dbl> -1.688699, -1.688699, -1.684675, -1.684675, -1.6…
## $ pitch_belt           <dbl> 0.3475911, 0.3475911, 0.3466984, 0.3475911, 0.34…
## $ yaw_belt             <dbl> -0.8746438, -0.8746438, -0.8746438, -0.8746438, …
## $ total_accel_belt     <dbl> -1.077169, -1.077169, -1.077169, -1.077169, -1.0…
## $ gyros_belt_x         <dbl> 0.02825354, 0.02825354, 0.12397658, 0.12397658, …
## $ gyros_belt_y         <dbl> -0.5033013, -0.5033013, -0.5033013, -0.2503901, …
## $ gyros_belt_z         <dbl> 0.4511467, 0.4511467, 0.4101324, 0.4511467, 0.45…
## $ magnet_belt_x        <dbl> -0.9091306, -0.8936621, -0.9555360, -0.9555360, …
## $ magnet_belt_y        <dbl> 0.14668236, 0.17483533, 0.28744721, 0.17483533, …
## $ magnet_belt_z        <dbl> 0.4940498, 0.6169178, 0.5401253, 0.6629933, 0.50…
## $ roll_arm             <dbl> -1.995914, -1.995914, -1.995914, -1.995914, -1.9…
## $ pitch_arm            <dbl> 0.8869495, 0.8869495, 0.8739245, 0.8739245, 0.87…
## $ yaw_arm              <dbl> -2.248118, -2.248118, -2.248118, -2.248118, -2.2…
## $ total_accel_arm      <dbl> 0.7983885, 0.7983885, 0.7983885, 0.7983885, 0.79…
## $ gyros_arm_x          <dbl> -0.023398464, -0.013356754, -0.013356754, -0.023…
## $ gyros_arm_z          <dbl> -0.5242504, -0.5242504, -0.4521621, -0.4882063, …
## $ accel_arm_x          <dbl> -1.252574, -1.258063, -1.258063, -1.258063, -1.2…
## $ accel_arm_y          <dbl> 0.6990345, 0.7081414, 0.7172484, 0.7172484, 0.71…
## $ accel_arm_z          <dbl> -0.3757457, -0.3978461, -0.3757457, -0.3757457, …
## $ magnet_arm_x         <dbl> -1.262226, -1.262226, -1.271247, -1.275757, -1.2…
## $ magnet_arm_y         <dbl> 0.8914890, 0.9260650, 0.9260650, 0.8914890, 0.91…
## $ magnet_arm_z         <dbl> 0.6445461, 0.6354087, 0.6323628, 0.6140879, 0.63…
## $ roll_dumbbell        <dbl> -0.1599906, -0.1628751, -0.1545630, -0.1553146, …
## $ pitch_dumbbell       <dbl> -1.612922, -1.607095, -1.610217, -1.611155, -1.6…
## $ yaw_dumbbell         <dbl> -1.046473, -1.049710, -1.046469, -1.046219, -1.0…
## $ total_accel_dumbbell <dbl> 2.273763, 2.273763, 2.273763, 2.273763, 2.273763…
## $ gyros_dumbbell_x     <dbl> -0.4497124, -0.4497124, -0.4497124, -0.4497124, …
## $ gyros_dumbbell_y     <dbl> -0.1280087, -0.1280087, -0.1280087, -0.1280087, …
## $ gyros_dumbbell_z     <dbl> 0.4527082, 0.4527082, 0.3907169, 0.4527082, 0.45…
## $ accel_dumbbell_x     <dbl> -3.054932, -3.025177, -3.025177, -3.040055, -3.0…
## $ accel_dumbbell_y     <dbl> -0.07404577, -0.08641970, -0.06167183, -0.061671…
## $ accel_dumbbell_z     <dbl> -2.122208, -2.113073, -2.103939, -2.113073, -2.1…
## $ magnet_dumbbell_x    <dbl> -0.6800512, -0.6859291, -0.6594787, -0.6653566, …
## $ magnet_dumbbell_y    <dbl> 0.2197180, 0.2349672, 0.2502163, 0.2166682, 0.22…
## $ magnet_dumbbell_z    <dbl> -0.7957626, -0.7814166, -0.7598976, -0.8172817, …
## $ roll_forearm         <dbl> -0.05787166, -0.05880075, -0.06065893, -0.061588…
## $ pitch_forearm        <dbl> -2.640451, -2.640451, -2.640451, -2.640451, -2.6…
## $ yaw_forearm          <dbl> -1.671854, -1.662162, -1.662162, -1.662162, -1.6…
## $ total_accel_forearm  <dbl> 0.1297607, 0.1297607, 0.1297607, 0.1297607, 0.12…
## $ gyros_forearm_x      <dbl> -0.2102132, -0.2102132, -0.2261615, -0.2261615, …
## $ gyros_forearm_y      <dbl> -0.02850046, -0.03773609, -0.03773609, -0.028500…
## $ gyros_forearm_z      <dbl> -0.2659969, -0.2329282, -0.2329282, -0.2659969, …
## $ accel_forearm_x      <dbl> 1.405146, 1.427344, 1.388498, 1.388498, 1.410696…
## $ accel_forearm_y      <dbl> 0.1944250, 0.1994295, 0.2094385, 0.2094385, 0.19…
## $ accel_forearm_z      <dbl> -1.151821, -1.137345, -1.144583, -1.144583, -1.1…
## $ magnet_forearm_x     <dbl> 0.8545319, 0.8516389, 0.8574250, 0.8545319, 0.87…
## $ magnet_forearm_y     <dbl> 0.5370548, 0.5449322, 0.5449322, 0.5390241, 0.54…
## $ magnet_forearm_z     <dbl> 0.2185807, 0.1995479, 0.1995479, 0.2104238, 0.22…
## $ min                  <dbl> -0.3257794, -0.3257794, -0.3257794, -0.3257794, …
## $ hour                 <dbl> -1.601362, -1.601362, -1.601362, -1.601362, -1.6…
## $ mon                  <dbl> 0.7007771, 0.7007771, 0.7007771, 0.7007771, 0.70…
## $ wday                 <dbl> -1.029067, -1.029067, -1.029067, -1.029067, -1.0…
## $ classe               <fct> A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, …
```

```r
data_testing <- 
    data_recipe %>% 
    bake(testing(data_split))

data_testing %>% 
    glimpse()
```

```
## Rows: 3,922
## Columns: 58
## $ user_name            <fct> carlitos, carlitos, carlitos, carlitos, carlitos…
## $ raw_timestamp_part_1 <dbl> 1.255076, 1.255081, 1.255081, 1.255081, 1.255081…
## $ raw_timestamp_part_2 <dbl> 1.066454210, -0.214774510, -0.061392584, 0.49534…
## $ cvtd_timestamp       <fct> 2011-12-05 11:23:00, 2011-12-05 11:23:00, 2011-1…
## $ new_window           <fct> no, no, no, no, no, no, no, no, no, no, no, no, …
## $ num_window           <dbl> -1.688699, -1.684675, -1.684675, -1.684675, -1.6…
## $ pitch_belt           <dbl> 0.3475911, 0.3502690, 0.3520543, 0.3511617, 0.34…
## $ yaw_belt             <dbl> -0.8746438, -0.8746438, -0.8746438, -0.8746438, …
## $ total_accel_belt     <dbl> -1.077169, -1.077169, -1.077169, -1.077169, -1.0…
## $ gyros_belt_x         <dbl> 0.12397658, 0.12397658, 0.17183809, 0.02825354, …
## $ gyros_belt_y         <dbl> -0.5033013, -0.5033013, -0.5033013, -0.5033013, …
## $ gyros_belt_z         <dbl> 0.4511467, 0.4511467, 0.5331753, 0.5331753, 0.45…
## $ magnet_belt_x        <dbl> -0.9710045, -0.8936621, -0.9091306, -0.8627251, …
## $ magnet_belt_y        <dbl> 0.40005909, 0.25929424, 0.42821206, -0.05038844,…
## $ magnet_belt_z        <dbl> 0.5247668, 0.4940498, 0.5708423, 0.6169178, 0.49…
## $ roll_arm             <dbl> -1.995914, -1.995914, -1.995914, -2.009639, -2.0…
## $ pitch_arm            <dbl> 0.8869495, 0.8641557, 0.8576432, 0.8478744, 0.84…
## $ yaw_arm              <dbl> -2.248118, -2.248118, -2.248118, -2.248118, -2.2…
## $ total_accel_arm      <dbl> 0.7983885, 0.7983885, 0.7983885, 0.7983885, 0.79…
## $ gyros_arm_x          <dbl> -0.013356754, -0.013356754, -0.013356754, -0.013…
## $ gyros_arm_z          <dbl> -0.5242504, -0.4882063, -0.5242504, -0.5422725, …
## $ accel_arm_x          <dbl> -1.263551, -1.258063, -1.252574, -1.258063, -1.2…
## $ accel_arm_y          <dbl> 0.7081414, 0.7172484, 0.7081414, 0.6990345, 0.69…
## $ accel_arm_z          <dbl> -0.3904793, -0.3831125, -0.3831125, -0.3610121, …
## $ magnet_arm_x         <dbl> -1.264481, -1.271247, -1.280268, -1.259970, -1.2…
## $ magnet_arm_y         <dbl> 0.8914890, 0.8964285, 0.8766708, 0.9063073, 0.90…
## $ magnet_arm_z         <dbl> 0.6354087, 0.6262712, 0.6445461, 0.6232254, 0.62…
## $ roll_dumbbell        <dbl> -0.1588656, -0.1643059, -0.1560073, -0.1557159, …
## $ pitch_dumbbell       <dbl> -1.616795, -1.608972, -1.622547, -1.606383, -1.6…
## $ yaw_dumbbell         <dbl> -1.044491, -1.049180, -1.041281, -1.048444, -1.0…
## $ total_accel_dumbbell <dbl> 2.273763, 2.273763, 2.273763, 2.273763, 2.273763…
## $ gyros_dumbbell_x     <dbl> -0.4497124, -0.4497124, -0.4497124, -0.4497124, …
## $ gyros_dumbbell_y     <dbl> -0.12800867, -0.12800867, -0.12800867, -0.128008…
## $ gyros_dumbbell_z     <dbl> 0.4527082, 0.4527082, 0.4527082, 0.4527082, 0.39…
## $ accel_dumbbell_x     <dbl> -3.040055, -3.054932, -3.069810, -3.040055, -3.0…
## $ accel_dumbbell_y     <dbl> -0.07404577, -0.08641970, -0.06167183, -0.061671…
## $ accel_dumbbell_z     <dbl> -2.103939, -2.131343, -2.113073, -2.122208, -2.1…
## $ magnet_dumbbell_x    <dbl> -0.6682955, -0.6682955, -0.6771123, -0.6653566, …
## $ magnet_dumbbell_y    <dbl> 0.2288675, 0.2410668, 0.2136184, 0.2319173, 0.22…
## $ magnet_dumbbell_z    <dbl> -0.7885896, -0.8603197, -0.8244547, -0.8531467, …
## $ roll_forearm         <dbl> -0.05880075, -0.06344619, -0.06437528, -0.069949…
## $ pitch_forearm        <dbl> -2.640451, -2.636909, -2.636909, -2.643993, -2.6…
## $ yaw_forearm          <dbl> -1.671854, -1.662162, -1.662162, -1.652470, -1.6…
## $ total_accel_forearm  <dbl> 0.1297607, 0.1297607, 0.1297607, 0.1297607, 0.12…
## $ gyros_forearm_x      <dbl> -0.2261615, -0.2261615, -0.2261615, -0.2261615, …
## $ gyros_forearm_y      <dbl> -0.028500457, -0.037736090, -0.028500457, -0.028…
## $ gyros_forearm_z      <dbl> -0.2659969, -0.2329282, -0.2659969, -0.2329282, …
## $ accel_forearm_x      <dbl> 1.405146, 1.410696, 1.394048, 1.416245, 1.405146…
## $ accel_forearm_y      <dbl> 0.1944250, 0.2044340, 0.2044340, 0.1994295, 0.19…
## $ accel_forearm_z      <dbl> -1.159060, -1.137345, -1.151821, -1.151821, -1.1…
## $ magnet_forearm_x     <dbl> 0.8516389, 0.8776760, 0.8400669, 0.8661040, 0.87…
## $ magnet_forearm_y     <dbl> 0.5508403, 0.5488710, 0.5409935, 0.5409935, 0.54…
## $ magnet_forearm_z     <dbl> 0.2104238, 0.2131428, 0.2104238, 0.2049858, 0.19…
## $ min                  <dbl> -0.3257794, -0.3257794, -0.3257794, -0.3257794, …
## $ hour                 <dbl> -1.601362, -1.601362, -1.601362, -1.601362, -1.6…
## $ mon                  <dbl> 0.7007771, 0.7007771, 0.7007771, 0.7007771, 0.70…
## $ wday                 <dbl> -1.029067, -1.029067, -1.029067, -1.029067, -1.0…
## $ classe               <fct> A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, …
```

## random forest


```r
library(ranger)
set.seed(42)
model_ranger <- 
    rand_forest(trees = 1000, mode = "classification") %>% 
    set_engine("ranger", num.threads = parallel::detectCores()) %>% 
    fit(classe ~ ., data = data_training)

model_ranger %>% 
    predict(data_testing) %>% 
    bind_cols(data_testing) %>% 
    metrics(truth = classe, estimate = .pred_class)
```

```
## # A tibble: 2 x 3
##   .metric  .estimator .estimate
##   <chr>    <chr>          <dbl>
## 1 accuracy multiclass     0.998
## 2 kap      multiclass     0.997
```

```r
model_ranger %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    gain_curve(classe, .pred_A:.pred_E) %>%
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

```r
model_ranger %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-3-2.png)<!-- -->

```r
model_ranger %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_ranger, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    metrics(classe, .pred_A:.pred_E, estimate = .pred_class)
```

```
## # A tibble: 4 x 3
##   .metric     .estimator .estimate
##   <chr>       <chr>          <dbl>
## 1 accuracy    multiclass    0.998 
## 2 kap         multiclass    0.997 
## 3 mn_log_loss multiclass    0.0591
## 4 roc_auc     hand_till     1.00
```

## Other


```r
library(kernlab)
set.seed(42)
model_svm <- 
    svm_poly() %>% 
    set_engine("kernlab") %>% 
    set_mode("classification") %>% 
    fit(classe ~ ., data = data_training)
```

```
##  Setting default kernel parameters
```

```r
model_svm %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    gain_curve(classe, .pred_A:.pred_E) %>%
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

```r
model_svm %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-4-2.png)<!-- -->

```r
model_svm %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_svm, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    metrics(classe, .pred_A:.pred_E, estimate = .pred_class)
```

```
## # A tibble: 4 x 3
##   .metric     .estimator .estimate
##   <chr>       <chr>          <dbl>
## 1 accuracy    multiclass     0.897
## 2 kap         multiclass     0.870
## 3 mn_log_loss multiclass     0.501
## 4 roc_auc     hand_till      0.962
```


```r
library(nnet)
set.seed(42)
model_nn <- 
    mlp() %>% 
    set_engine("nnet") %>% 
    set_mode("classification") %>% 
    fit(classe ~ ., data = data_training)

model_nn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    gain_curve(classe, .pred_A:.pred_E) %>%
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

```r
model_nn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-5-2.png)<!-- -->

```r
model_nn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_nn, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    metrics(classe, .pred_A:.pred_E, estimate = .pred_class)
```

```
## # A tibble: 4 x 3
##   .metric     .estimator .estimate
##   <chr>       <chr>          <dbl>
## 1 accuracy    multiclass     0.828
## 2 kap         multiclass     0.783
## 3 mn_log_loss multiclass     1.11 
## 4 roc_auc     hand_till      0.966
```



```r
library(kknn)
set.seed(42)
model_kknn <- 
    nearest_neighbor() %>% 
    set_engine("kknn") %>% 
    set_mode("classification") %>% 
    fit(classe ~ ., data = data_training)

model_kknn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    gain_curve(classe, .pred_A:.pred_E) %>%
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

```r
model_kknn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-6-2.png)<!-- -->

```r
model_kknn %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_kknn, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    metrics(classe, .pred_A:.pred_E, estimate = .pred_class)
```

```
## # A tibble: 4 x 3
##   .metric     .estimator .estimate
##   <chr>       <chr>          <dbl>
## 1 accuracy    multiclass     0.985
## 2 kap         multiclass     0.982
## 3 mn_log_loss multiclass     0.240
## 4 roc_auc     hand_till      0.997
```


```r
set.seed(42)
model_mr <- 
    multinom_reg() %>% 
    set_engine("nnet") %>% 
    set_mode("classification") %>% 
    fit(classe ~ ., data = data_training)

model_mr %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    gain_curve(classe, .pred_A:.pred_E) %>%
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

```r
model_mr %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(data_testing) %>% 
    roc_curve(classe, .pred_A:.pred_E) %>% 
    autoplot()
```

![](project_files/figure-html/unnamed-chunk-7-2.png)<!-- -->

```r
model_mr %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_mr, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    metrics(classe, .pred_A:.pred_E, estimate = .pred_class)
```

```
## # A tibble: 4 x 3
##   .metric     .estimator .estimate
##   <chr>       <chr>          <dbl>
## 1 accuracy    multiclass     0.870
## 2 kap         multiclass     0.836
## 3 mn_log_loss multiclass     0.353
## 4 roc_auc     hand_till      0.981
```

```r
model_mr %>% 
    predict(data_testing, type = "prob") %>% 
    bind_cols(predict(model_mr, data_testing)) %>% 
    bind_cols(select(data_testing, classe)) %>% 
    glimpse()
```

```
## Rows: 3,922
## Columns: 7
## $ .pred_A     <dbl> 0.9702565, 0.9768266, 0.9721287, 0.9502181, 0.9743687, 0.…
## $ .pred_B     <dbl> 0.0009371992, 0.0006954384, 0.0006590411, 0.0011025929, 0…
## $ .pred_C     <dbl> 0.02700948, 0.02062670, 0.02528758, 0.04080535, 0.0224776…
## $ .pred_D     <dbl> 0.001735525, 0.001784549, 0.001862701, 0.007578773, 0.002…
## $ .pred_E     <dbl> 6.134722e-05, 6.672845e-05, 6.197705e-05, 2.951567e-04, 9…
## $ .pred_class <fct> A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, …
## $ classe      <fct> A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, A, …
```

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

