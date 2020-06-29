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
```


```r
data_path          <- "./data"
training_file_path <- file.path(data_path, "training.csv")
testing_file_path  <- file.path(data_path, "testing.csv")
training_file_url  <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
testing_file_url   <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

if (!dir.exists(data_path)){
    dir.create(data_path)
}

if (!file.exists(training_file_path)){
    download.file(training_file_url, training_file_path, method = "curl")
}

if (!file.exists(testing_file_path)){
    download.file(testing_file_url, testing_file_path, method = "curl")
}
```


```r
set.seed(42)

training <- read_csv(training_file_path)
testing <- read_csv(testing_file_path)

# skimr::skim(training)
# skimr::skim(testing)
```


```r
# training %>% 
#     summarise(across(everything(), ~ sum(is.na(.x)))) %>% 
#     skimr::skim()

training %>% 
    summarise(across(everything(), ~ all(sum(is.na(.x))) > 0)) %>% 
    select(where(isTRUE)) %>%
    colnames() -> columns_to_remove

training %<>% 
    select(!all_of(columns_to_remove) & !X1) %>%
    mutate(across(where(is.character), as.factor))

testing %<>% 
    select(!all_of(columns_to_remove) & !X1 & !problem_id) %>%
    mutate(across(where(is.character), as.factor))

skimr::skim(training)
```


Table: Data summary

                                    
-------------------------  ---------
Name                       training 
Number of rows             19622    
Number of columns          59       
_______________________             
Column type frequency:              
factor                     4        
numeric                    55       
________________________            
Group variables            None     
-------------------------  ---------


**Variable type: factor**

skim_variable     n_missing   complete_rate  ordered    n_unique  top_counts                                 
---------------  ----------  --------------  --------  ---------  -------------------------------------------
user_name                 0               1  FALSE             6  ade: 3892, cha: 3536, jer: 3402, car: 3112 
cvtd_timestamp            0               1  FALSE            20  28/: 1498, 05/: 1497, 30/: 1440, 05/: 1425 
new_window                0               1  FALSE             2  no: 19216, yes: 406                        
classe                    0               1  FALSE             5  A: 5580, B: 3797, E: 3607, C: 3422         


**Variable type: numeric**

skim_variable           n_missing   complete_rate            mean          sd             p0             p25             p50             p75           p100  hist  
---------------------  ----------  --------------  --------------  ----------  -------------  --------------  --------------  --------------  -------------  ------
raw_timestamp_part_1            0               1   1322827119.27   204927.68    1.32249e+09   1322673099.00   1322832920.00   1323084264.00   1.323095e+09  ▃▃▇▁▆ 
raw_timestamp_part_2            0               1       500656.14   288222.88    2.94000e+02       252912.25       496380.00       751890.75   9.988010e+05  ▇▇▇▇▇ 
num_window                      0               1          430.64      247.91    1.00000e+00          222.00          424.00          644.00   8.640000e+02  ▇▇▇▇▇ 
roll_belt                       0               1           64.41       62.75   -2.89000e+01            1.10          113.00          123.00   1.620000e+02  ▇▁▁▅▅ 
pitch_belt                      0               1            0.31       22.35   -5.58000e+01            1.76            5.28           14.90   6.030000e+01  ▃▁▇▅▁ 
yaw_belt                        0               1          -11.21       95.19   -1.80000e+02          -88.30          -13.00           12.90   1.790000e+02  ▁▇▅▁▃ 
total_accel_belt                0               1           11.31        7.74    0.00000e+00            3.00           17.00           18.00   2.900000e+01  ▇▁▂▆▁ 
gyros_belt_x                    0               1           -0.01        0.21   -1.04000e+00           -0.03            0.03            0.11   2.220000e+00  ▁▇▁▁▁ 
gyros_belt_y                    0               1            0.04        0.08   -6.40000e-01            0.00            0.02            0.11   6.400000e-01  ▁▁▇▁▁ 
gyros_belt_z                    0               1           -0.13        0.24   -1.46000e+00           -0.20           -0.10           -0.02   1.620000e+00  ▁▂▇▁▁ 
accel_belt_x                    0               1           -5.59       29.64   -1.20000e+02          -21.00          -15.00           -5.00   8.500000e+01  ▁▁▇▁▂ 
accel_belt_y                    0               1           30.15       28.58   -6.90000e+01            3.00           35.00           61.00   1.640000e+02  ▁▇▇▁▁ 
accel_belt_z                    0               1          -72.59      100.45   -2.75000e+02         -162.00         -152.00           27.00   1.050000e+02  ▁▇▁▅▃ 
magnet_belt_x                   0               1           55.60       64.18   -5.20000e+01            9.00           35.00           59.00   4.850000e+02  ▇▁▂▁▁ 
magnet_belt_y                   0               1          593.68       35.68    3.54000e+02          581.00          601.00          610.00   6.730000e+02  ▁▁▁▇▃ 
magnet_belt_z                   0               1         -345.48       65.21   -6.23000e+02         -375.00         -320.00         -306.00   2.930000e+02  ▁▇▁▁▁ 
roll_arm                        0               1           17.83       72.74   -1.80000e+02          -31.78            0.00           77.30   1.800000e+02  ▁▃▇▆▂ 
pitch_arm                       0               1           -4.61       30.68   -8.88000e+01          -25.90            0.00           11.20   8.850000e+01  ▁▅▇▂▁ 
yaw_arm                         0               1           -0.62       71.36   -1.80000e+02          -43.10            0.00           45.88   1.800000e+02  ▁▃▇▃▂ 
total_accel_arm                 0               1           25.51       10.52    1.00000e+00           17.00           27.00           33.00   6.600000e+01  ▃▆▇▁▁ 
gyros_arm_x                     0               1            0.04        1.99   -6.37000e+00           -1.33            0.08            1.57   4.870000e+00  ▁▃▇▆▂ 
gyros_arm_y                     0               1           -0.26        0.85   -3.44000e+00           -0.80           -0.24            0.14   2.840000e+00  ▁▂▇▂▁ 
gyros_arm_z                     0               1            0.27        0.55   -2.33000e+00           -0.07            0.23            0.72   3.020000e+00  ▁▂▇▂▁ 
accel_arm_x                     0               1          -60.24      182.04   -4.04000e+02         -242.00          -44.00           84.00   4.370000e+02  ▇▅▇▅▁ 
accel_arm_y                     0               1           32.60      109.87   -3.18000e+02          -54.00           14.00          139.00   3.080000e+02  ▁▃▇▆▂ 
accel_arm_z                     0               1          -71.25      134.65   -6.36000e+02         -143.00          -47.00           23.00   2.920000e+02  ▁▁▅▇▁ 
magnet_arm_x                    0               1          191.72      443.64   -5.84000e+02         -300.00          289.00          637.00   7.820000e+02  ▆▃▂▃▇ 
magnet_arm_y                    0               1          156.61      201.91   -3.92000e+02           -9.00          202.00          323.00   5.830000e+02  ▁▅▅▇▂ 
magnet_arm_z                    0               1          306.49      326.62   -5.97000e+02          131.25          444.00          545.00   6.940000e+02  ▁▂▂▃▇ 
roll_dumbbell                   0               1           23.84       69.93   -1.53710e+02          -18.49           48.17           67.61   1.535500e+02  ▂▂▃▇▂ 
pitch_dumbbell                  0               1          -10.78       36.99   -1.49590e+02          -40.89          -20.96           17.50   1.494000e+02  ▁▆▇▂▁ 
yaw_dumbbell                    0               1            1.67       82.52   -1.50870e+02          -77.64           -3.32           79.64   1.549500e+02  ▃▇▅▅▆ 
total_accel_dumbbell            0               1           13.72       10.23    0.00000e+00            4.00           10.00           19.00   5.800000e+01  ▇▅▃▁▁ 
gyros_dumbbell_x                0               1            0.16        1.51   -2.04000e+02           -0.03            0.13            0.35   2.220000e+00  ▁▁▁▁▇ 
gyros_dumbbell_y                0               1            0.05        0.61   -2.10000e+00           -0.14            0.03            0.21   5.200000e+01  ▇▁▁▁▁ 
gyros_dumbbell_z                0               1           -0.13        2.29   -2.38000e+00           -0.31           -0.13            0.03   3.170000e+02  ▇▁▁▁▁ 
accel_dumbbell_x                0               1          -28.62       67.32   -4.19000e+02          -50.00           -8.00           11.00   2.350000e+02  ▁▁▆▇▁ 
accel_dumbbell_y                0               1           52.63       80.75   -1.89000e+02           -8.00           41.50          111.00   3.150000e+02  ▁▇▇▅▁ 
accel_dumbbell_z                0               1          -38.32      109.47   -3.34000e+02         -142.00           -1.00           38.00   3.180000e+02  ▁▆▇▃▁ 
magnet_dumbbell_x               0               1         -328.48      339.72   -6.43000e+02         -535.00         -479.00         -304.00   5.920000e+02  ▇▂▁▁▂ 
magnet_dumbbell_y               0               1          220.97      326.87   -3.60000e+03          231.00          311.00          390.00   6.330000e+02  ▁▁▁▁▇ 
magnet_dumbbell_z               0               1           46.05      139.96   -2.62000e+02          -45.00           13.00           95.00   4.520000e+02  ▁▇▆▂▂ 
roll_forearm                    0               1           33.83      108.04   -1.80000e+02           -0.74           21.70          140.00   1.800000e+02  ▃▂▇▂▇ 
pitch_forearm                   0               1           10.71       28.15   -7.25000e+01            0.00            9.24           28.40   8.980000e+01  ▁▁▇▃▁ 
yaw_forearm                     0               1           19.21      103.22   -1.80000e+02          -68.60            0.00          110.00   1.800000e+02  ▅▅▇▆▇ 
total_accel_forearm             0               1           34.72       10.06    0.00000e+00           29.00           36.00           41.00   1.080000e+02  ▁▇▂▁▁ 
gyros_forearm_x                 0               1            0.16        0.65   -2.20000e+01           -0.22            0.05            0.56   3.970000e+00  ▁▁▁▁▇ 
gyros_forearm_y                 0               1            0.08        3.10   -7.02000e+00           -1.46            0.03            1.62   3.110000e+02  ▇▁▁▁▁ 
gyros_forearm_z                 0               1            0.15        1.75   -8.09000e+00           -0.18            0.08            0.49   2.310000e+02  ▇▁▁▁▁ 
accel_forearm_x                 0               1          -61.65      180.59   -4.98000e+02         -178.00          -57.00           76.00   4.770000e+02  ▂▆▇▅▁ 
accel_forearm_y                 0               1          163.66      200.13   -6.32000e+02           57.00          201.00          312.00   9.230000e+02  ▁▂▇▅▁ 
accel_forearm_z                 0               1          -55.29      138.40   -4.46000e+02         -182.00          -39.00           26.00   2.910000e+02  ▁▇▅▅▃ 
magnet_forearm_x                0               1         -312.58      346.96   -1.28000e+03         -616.00         -378.00          -73.00   6.720000e+02  ▁▇▇▅▁ 
magnet_forearm_y                0               1          380.12      509.37   -8.96000e+02            2.00          591.00          737.00   1.480000e+03  ▂▂▂▇▁ 
magnet_forearm_z                0               1          393.61      369.27   -9.73000e+02          191.00          511.00          653.00   1.090000e+03  ▁▁▂▇▃ 

```r
# skimr::skim(testing)
```




