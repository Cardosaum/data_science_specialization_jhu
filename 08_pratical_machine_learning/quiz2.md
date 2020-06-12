---
title: "Quiz 02"
author: "Matheus Cardoso"
date: "Jun 12, 2020"
output: 
  html_document: 
    fig_caption: yes
    highlight: zenburn
    keep_md: yes
    theme: simplex
    toc: yes
    toc_float: yes
  pdf_document: 
    toc: yes
    fig_caption: yes
    highlight: zenburn
editor_options: 
  chunk_output_type: console
---



# Q1 

Load the Alzheimer's disease data using the commands:


```r
library(AppliedPredictiveModeling)
data(AlzheimerDisease)
```

Which of the following commands will create non-overlapping training and test sets with about 50% of the observations assigned to each?

## A1


```r
adData = data.frame(diagnosis,predictors)
testIndex = createDataPartition(diagnosis, p = 0.50,list=FALSE)
training = adData[-testIndex,]
testing = adData[testIndex,]
```

# Q2

Load the cement data using the commands:


```r
library(AppliedPredictiveModeling)
data(concrete)
library(caret)
set.seed(1000)
inTrain = createDataPartition(mixtures$CompressiveStrength, p = 3/4)[[1]]
training = mixtures[ inTrain,]
testing = mixtures[-inTrain,]
```

Make a plot of the outcome (CompressiveStrength) versus the index of the samples. Color by each of the variables in the data set (you may find the cut2() function in the Hmisc package useful for turning continuous covariates into factors). What do you notice in these plots?


```r
str(training)
```

```
## 'data.frame':	774 obs. of  9 variables:
##  $ Cement             : num  0.2231 0.2217 0.1492 0.1492 0.0853 ...
##  $ BlastFurnaceSlag   : num  0 0 0.0639 0.0639 0.0569 ...
##  $ FlyAsh             : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ Water              : num  0.0669 0.0665 0.1023 0.1023 0.0825 ...
##  $ Superplasticizer   : num  0.00103 0.00103 0 0 0 ...
##  $ CoarseAggregate    : num  0.43 0.433 0.418 0.418 0.42 ...
##  $ FineAggregate      : num  0.279 0.278 0.266 0.266 0.355 ...
##  $ Age                : int  28 28 270 365 360 90 365 28 28 90 ...
##  $ CompressiveStrength: num  80 61.9 40.3 41 44.3 ...
```

```r
names(training)
```

```
## [1] "Cement"              "BlastFurnaceSlag"    "FlyAsh"             
## [4] "Water"               "Superplasticizer"    "CoarseAggregate"    
## [7] "FineAggregate"       "Age"                 "CompressiveStrength"
```

```r
# make one plot for each variable
for (i in names(training)) {
    if (str_detect(i, "CompressiveStrength", negate = T)) {
        p <- ggplot(training) +
                geom_point(aes(seq_along(CompressiveStrength), CompressiveStrength, color = .data[[i]]))
        print(p)
    }
}
```

![](quiz1_files/figure-html/a2-1.png)<!-- -->![](quiz1_files/figure-html/a2-2.png)<!-- -->![](quiz1_files/figure-html/a2-3.png)<!-- -->![](quiz1_files/figure-html/a2-4.png)<!-- -->![](quiz1_files/figure-html/a2-5.png)<!-- -->![](quiz1_files/figure-html/a2-6.png)<!-- -->![](quiz1_files/figure-html/a2-7.png)<!-- -->![](quiz1_files/figure-html/a2-8.png)<!-- -->

## A2

There is a non-random pattern in the plot of the outcome versus index that does not appear to be perfectly explained by any predictor suggesting a variable may be missing.

# Q3

Load the cement data using the commands:


```r
library(AppliedPredictiveModeling)
data(concrete)
library(caret)
set.seed(1000)
inTrain = createDataPartition(mixtures$CompressiveStrength, p = 3/4)[[1]]
training = mixtures[ inTrain,]
testing = mixtures[-inTrain,]
```

Make a histogram and confirm the SuperPlasticizer variable is skewed. Normally you might use the log transform to try to make the data more symmetric. Why would that be a poor choice for this variable?


```r
str(training)
```

```
## 'data.frame':	774 obs. of  9 variables:
##  $ Cement             : num  0.2231 0.2217 0.1492 0.1492 0.0853 ...
##  $ BlastFurnaceSlag   : num  0 0 0.0639 0.0639 0.0569 ...
##  $ FlyAsh             : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ Water              : num  0.0669 0.0665 0.1023 0.1023 0.0825 ...
##  $ Superplasticizer   : num  0.00103 0.00103 0 0 0 ...
##  $ CoarseAggregate    : num  0.43 0.433 0.418 0.418 0.42 ...
##  $ FineAggregate      : num  0.279 0.278 0.266 0.266 0.355 ...
##  $ Age                : int  28 28 270 365 360 90 365 28 28 90 ...
##  $ CompressiveStrength: num  80 61.9 40.3 41 44.3 ...
```

```r
names(training)
```

```
## [1] "Cement"              "BlastFurnaceSlag"    "FlyAsh"             
## [4] "Water"               "Superplasticizer"    "CoarseAggregate"    
## [7] "FineAggregate"       "Age"                 "CompressiveStrength"
```

```r
ggplot(training) +
    geom_histogram(aes(Superplasticizer))
```

![](quiz1_files/figure-html/a3-1.png)<!-- -->

## A3

There are values of zero so when you take the log() transform those values will be -Inf.

# Q4

Load the Alzheimer's disease data using the commands:


```r
library(caret)
library(AppliedPredictiveModeling)
set.seed(3433)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]
```

Find all the predictor variables in the training set that begin with IL. Perform principal components on these variables with the preProcess() function from the caret package. Calculate the number of principal components needed to capture 90% of the variance. How many are there?


```r
str(training)
```

```
## 'data.frame':	251 obs. of  131 variables:
##  $ diagnosis                       : Factor w/ 2 levels "Impaired","Control": 2 2 2 2 1 2 2 2 1 1 ...
##  $ ACE_CD143_Angiotensin_Converti  : num  2.003 1.521 1.681 2.401 0.431 ...
##  $ ACTH_Adrenocorticotropic_Hormon : num  -1.386 -1.715 -1.609 -0.968 -1.273 ...
##  $ AXL                             : num  1.098 -0.145 0.683 0.191 -0.222 ...
##  $ Adiponectin                     : num  -5.36 -5.81 -5.12 -4.78 -5.22 ...
##  $ Alpha_1_Antichymotrypsin        : num  1.74 1.19 1.28 2.13 1.31 ...
##  $ Alpha_1_Antitrypsin             : num  -12.6 -13.6 -15.5 -11.1 -12.1 ...
##  $ Alpha_1_Microglobulin           : num  -2.58 -2.88 -3.17 -2.34 -2.55 ...
##  $ Alpha_2_Macroglobulin           : num  -72.7 -136.5 -98.4 -144.9 -154.6 ...
##  $ Angiopoietin_2_ANG_2            : num  1.0647 0.8329 0.9163 0.9555 -0.0513 ...
##  $ Angiotensinogen                 : num  2.51 1.98 2.38 2.86 2.52 ...
##  $ Apolipoprotein_A_IV             : num  -1.43 -1.66 -2.12 -1.17 -1.39 ...
##  $ Apolipoprotein_A1               : num  -7.4 -7.68 -8.05 -6.73 -7.4 ...
##  $ Apolipoprotein_A2               : num  -0.2614 -0.6539 -1.2379 0.0953 -0.2744 ...
##  $ Apolipoprotein_B                : num  -4.62 -3.98 -6.52 -3.38 -2.96 ...
##  $ Apolipoprotein_CI               : num  -1.273 -1.715 -1.966 -0.755 -1.661 ...
##  $ Apolipoprotein_CIII             : num  -2.31 -2.75 -3 -1.51 -2.31 ...
##  $ Apolipoprotein_D                : num  2.08 1.34 1.44 1.63 1.92 ...
##  $ Apolipoprotein_E                : num  3.755 2.753 2.371 3.067 0.591 ...
##  $ Apolipoprotein_H                : num  -0.1573 -0.3448 -0.5317 0.6626 0.0972 ...
##  $ B_Lymphocyte_Chemoattractant_BL : num  2.3 1.67 1.98 2.3 2.48 ...
##  $ BMP_6                           : num  -2.2 -2.06 -1.98 -1.24 -1.88 ...
##  $ Beta_2_Microglobulin            : num  0.693 0.336 0.642 0.336 -0.545 ...
##  $ Betacellulin                    : int  34 49 52 67 51 41 42 58 32 43 ...
##  $ C_Reactive_Protein              : num  -4.07 -8.05 -6.21 -4.34 -7.56 ...
##  $ CD40                            : num  -0.796 -1.242 -1.124 -0.924 -1.784 ...
##  $ CD5L                            : num  0.0953 0.0953 -0.3285 0.3633 0.4055 ...
##  $ Calbindin                       : num  33.2 22.2 23.5 21.8 13.2 ...
##  $ Calcitonin                      : num  1.386 2.116 -0.151 1.308 1.629 ...
##  $ CgA                             : num  398 348 334 443 138 ...
##  $ Clusterin_Apo_J                 : num  3.56 2.77 2.83 3.04 2.56 ...
##  $ Complement_3                    : num  -10.4 -16.1 -13.2 -12.8 -12 ...
##  $ Complement_Factor_H             : num  3.57 4.47 3.1 7.25 3.57 ...
##  $ Connective_Tissue_Growth_Factor : num  0.531 0.642 0.531 0.916 0.993 ...
##  $ Cortisol                        : num  10 10 14 11 13 4.9 13 12 6.8 12 ...
##  $ Creatine_Kinase_MB              : num  -1.71 -1.38 -1.65 -1.63 -1.67 ...
##  $ Cystatin_C                      : num  9.04 8.95 9.58 8.98 7.84 ...
##  $ EGF_R                           : num  -0.135 -0.733 -0.422 -0.621 -1.111 ...
##  $ EN_RAGE                         : num  -3.69 -4.76 -2.94 -2.36 -3.44 ...
##  $ ENA_78                          : num  -1.35 -1.39 -1.37 -1.34 -1.36 ...
##  $ Eotaxin_3                       : int  53 62 44 64 57 64 64 64 82 73 ...
##  $ FAS                             : num  -0.0834 -0.6349 -0.478 -0.1278 -0.3285 ...
##  $ FSH_Follicle_Stimulation_Hormon : num  -0.652 -1.563 -0.59 -0.976 -1.683 ...
##  $ Fas_Ligand                      : num  3.1 1.36 2.54 4.04 2.41 ...
##  $ Fatty_Acid_Binding_Protein      : num  2.521 0.906 0.624 2.635 0.624 ...
##  $ Ferritin                        : num  3.33 3.18 3.14 2.69 1.85 ...
##  $ Fetuin_A                        : num  1.281 1.411 0.742 2.152 1.482 ...
##  $ Fibrinogen                      : num  -7.04 -7.2 -7.8 -6.98 -6.44 ...
##  $ GRO_alpha                       : num  1.38 1.41 1.37 1.4 1.4 ...
##  $ Gamma_Interferon_induced_Monokin: num  2.95 2.76 2.89 2.85 2.82 ...
##  $ Glutathione_S_Transferase_alpha : num  1.064 0.889 0.708 1.236 1.154 ...
##  $ HB_EGF                          : num  6.56 7.75 5.95 7.25 6.41 ...
##  $ HCC_4                           : num  -3.04 -3.65 -3.82 -3.15 -3.08 ...
##  $ Hepatocyte_Growth_Factor_HGF    : num  0.5878 0.0953 0.4055 0.5306 0.0953 ...
##  $ I_309                           : num  3.43 2.4 3.37 3.76 2.71 ...
##  $ ICAM_1                          : num  -0.1908 -0.462 -0.8573 0.0972 -0.9351 ...
##  $ IGF_BP_2                        : num  5.61 5.18 5.42 5.42 5.06 ...
##  $ IL_11                           : num  5.12 4.67 6.22 7.07 6.1 ...
##  $ IL_13                           : num  1.28 1.27 1.31 1.31 1.28 ...
##  $ IL_16                           : num  4.19 2.62 2.44 4.74 2.67 ...
##  $ IL_17E                          : num  5.73 4.15 4.7 4.2 3.64 ...
##  $ IL_1alpha                       : num  -6.57 -8.18 -7.6 -6.94 -8.18 ...
##  $ IL_3                            : num  -3.24 -4.65 -4.27 -3 -3.86 ...
##  $ IL_4                            : num  2.48 1.82 1.48 2.71 1.21 ...
##  $ IL_5                            : num  1.099 -0.248 0.788 1.163 -0.4 ...
##  $ IL_6                            : num  0.269 0.186 -0.371 -0.072 0.186 ...
##  $ IL_6_Receptor                   : num  0.6428 0.0967 0.5752 0.0967 -0.5173 ...
##  $ IL_7                            : num  4.81 1.01 2.34 4.29 2.78 ...
##  $ IL_8                            : num  1.71 1.69 1.72 1.76 1.71 ...
##  $ IP_10_Inducible_Protein_10      : num  6.24 5.05 5.6 6.37 5.48 ...
##  $ IgA                             : num  -6.81 -6.32 -7.62 -4.65 -5.81 ...
##  $ Insulin                         : num  -0.626 -1.447 -1.485 -0.3 -1.341 ...
##  $ Kidney_Injury_Molecule_1_KIM_1  : num  -1.2 -1.19 -1.23 -1.16 -1.12 ...
##  $ LOX_1                           : num  1.705 1.163 1.224 1.361 0.642 ...
##  $ Leptin                          : num  -1.529 -1.662 -1.269 -0.915 -1.361 ...
##  $ Lipoprotein_a                   : num  -4.27 -5.84 -4.99 -2.94 -4.51 ...
##  $ MCP_1                           : num  6.74 6.77 6.78 6.72 6.54 ...
##  $ MCP_2                           : num  1.981 0.401 1.981 2.221 2.334 ...
##  $ MIF                             : num  -1.24 -2.3 -1.66 -1.9 -2.04 ...
##  $ MIP_1alpha                      : num  4.97 4.05 4.93 6.45 4.6 ...
##  $ MIP_1beta                       : num  3.26 2.4 3.22 3.53 2.89 ...
##  $ MMP_2                           : num  4.48 2.87 2.97 3.69 2.92 ...
##  $ MMP_3                           : num  -2.21 -2.3 -1.77 -1.56 -3.04 ...
##  $ MMP10                           : num  -3.27 -2.73 -4.07 -2.62 -3.32 ...
##  $ MMP7                            : num  -3.774 -4.03 -6.856 -0.222 -1.922 ...
##  $ Myoglobin                       : num  -1.9 -1.39 -1.14 -1.77 -1.14 ...
##  $ NT_proBNP                       : num  4.55 4.25 4.11 4.47 4.19 ...
##  $ NrCAM                           : num  5 4.74 4.97 5.2 3.26 ...
##  $ Osteopontin                     : num  5.36 5.02 5.77 5.69 4.74 ...
##  $ PAI_1                           : num  1.004 0.438 0 0.252 0.438 ...
##  $ PAPP_A                          : num  -2.9 -2.94 -2.79 -2.94 -2.94 ...
##  $ PLGF                            : num  4.44 4.51 3.43 4.8 4.39 ...
##  $ PYY                             : num  3.22 2.89 2.83 3.66 3.33 ...
##  $ Pancreatic_polypeptide          : num  0.579 -0.892 -0.821 0.262 -0.478 ...
##  $ Prolactin                       : num  0 -0.1393 -0.0408 0.1823 -0.1508 ...
##  $ Prostatic_Acid_Phosphatase      : num  -1.62 -1.64 -1.74 -1.7 -1.76 ...
##  $ Protein_S                       : num  -1.78 -2.26 -2.7 -1.66 -2.36 ...
##  $ Pulmonary_and_Activation_Regulat: num  -0.844 -1.661 -1.109 -0.562 -1.171 ...
##  $ RANTES                          : num  -6.21 -6.65 -5.99 -6.32 -6.5 ...
##   [list output truncated]
```

```r
names(training)
```

```
##   [1] "diagnosis"                        "ACE_CD143_Angiotensin_Converti"  
##   [3] "ACTH_Adrenocorticotropic_Hormon"  "AXL"                             
##   [5] "Adiponectin"                      "Alpha_1_Antichymotrypsin"        
##   [7] "Alpha_1_Antitrypsin"              "Alpha_1_Microglobulin"           
##   [9] "Alpha_2_Macroglobulin"            "Angiopoietin_2_ANG_2"            
##  [11] "Angiotensinogen"                  "Apolipoprotein_A_IV"             
##  [13] "Apolipoprotein_A1"                "Apolipoprotein_A2"               
##  [15] "Apolipoprotein_B"                 "Apolipoprotein_CI"               
##  [17] "Apolipoprotein_CIII"              "Apolipoprotein_D"                
##  [19] "Apolipoprotein_E"                 "Apolipoprotein_H"                
##  [21] "B_Lymphocyte_Chemoattractant_BL"  "BMP_6"                           
##  [23] "Beta_2_Microglobulin"             "Betacellulin"                    
##  [25] "C_Reactive_Protein"               "CD40"                            
##  [27] "CD5L"                             "Calbindin"                       
##  [29] "Calcitonin"                       "CgA"                             
##  [31] "Clusterin_Apo_J"                  "Complement_3"                    
##  [33] "Complement_Factor_H"              "Connective_Tissue_Growth_Factor" 
##  [35] "Cortisol"                         "Creatine_Kinase_MB"              
##  [37] "Cystatin_C"                       "EGF_R"                           
##  [39] "EN_RAGE"                          "ENA_78"                          
##  [41] "Eotaxin_3"                        "FAS"                             
##  [43] "FSH_Follicle_Stimulation_Hormon"  "Fas_Ligand"                      
##  [45] "Fatty_Acid_Binding_Protein"       "Ferritin"                        
##  [47] "Fetuin_A"                         "Fibrinogen"                      
##  [49] "GRO_alpha"                        "Gamma_Interferon_induced_Monokin"
##  [51] "Glutathione_S_Transferase_alpha"  "HB_EGF"                          
##  [53] "HCC_4"                            "Hepatocyte_Growth_Factor_HGF"    
##  [55] "I_309"                            "ICAM_1"                          
##  [57] "IGF_BP_2"                         "IL_11"                           
##  [59] "IL_13"                            "IL_16"                           
##  [61] "IL_17E"                           "IL_1alpha"                       
##  [63] "IL_3"                             "IL_4"                            
##  [65] "IL_5"                             "IL_6"                            
##  [67] "IL_6_Receptor"                    "IL_7"                            
##  [69] "IL_8"                             "IP_10_Inducible_Protein_10"      
##  [71] "IgA"                              "Insulin"                         
##  [73] "Kidney_Injury_Molecule_1_KIM_1"   "LOX_1"                           
##  [75] "Leptin"                           "Lipoprotein_a"                   
##  [77] "MCP_1"                            "MCP_2"                           
##  [79] "MIF"                              "MIP_1alpha"                      
##  [81] "MIP_1beta"                        "MMP_2"                           
##  [83] "MMP_3"                            "MMP10"                           
##  [85] "MMP7"                             "Myoglobin"                       
##  [87] "NT_proBNP"                        "NrCAM"                           
##  [89] "Osteopontin"                      "PAI_1"                           
##  [91] "PAPP_A"                           "PLGF"                            
##  [93] "PYY"                              "Pancreatic_polypeptide"          
##  [95] "Prolactin"                        "Prostatic_Acid_Phosphatase"      
##  [97] "Protein_S"                        "Pulmonary_and_Activation_Regulat"
##  [99] "RANTES"                           "Resistin"                        
## [101] "S100b"                            "SGOT"                            
## [103] "SHBG"                             "SOD"                             
## [105] "Serum_Amyloid_P"                  "Sortilin"                        
## [107] "Stem_Cell_Factor"                 "TGF_alpha"                       
## [109] "TIMP_1"                           "TNF_RII"                         
## [111] "TRAIL_R3"                         "TTR_prealbumin"                  
## [113] "Tamm_Horsfall_Protein_THP"        "Thrombomodulin"                  
## [115] "Thrombopoietin"                   "Thymus_Expressed_Chemokine_TECK" 
## [117] "Thyroid_Stimulating_Hormone"      "Thyroxine_Binding_Globulin"      
## [119] "Tissue_Factor"                    "Transferrin"                     
## [121] "Trefoil_Factor_3_TFF3"            "VCAM_1"                          
## [123] "VEGF"                             "Vitronectin"                     
## [125] "von_Willebrand_Factor"            "age"                             
## [127] "tau"                              "p_tau"                           
## [129] "Ab_42"                            "male"                            
## [131] "Genotype"
```

```r
training_subset <- training %>% select(starts_with("IL")) 
names(training_subset)
```

```
##  [1] "IL_11"         "IL_13"         "IL_16"         "IL_17E"       
##  [5] "IL_1alpha"     "IL_3"          "IL_4"          "IL_5"         
##  [9] "IL_6"          "IL_6_Receptor" "IL_7"          "IL_8"
```

```r
data <- preProcess(
            training_subset,
            method = "pca",
            thresh = 0.9
            )
data
```

```
## Created from 251 samples and 12 variables
## 
## Pre-processing:
##   - centered (12)
##   - ignored (0)
##   - principal component signal extraction (12)
##   - scaled (12)
## 
## PCA needed 9 components to capture 90 percent of the variance
```

## A4

9

# Q5

Load the Alzheimer's disease data using the commands:


```r
library(caret)
library(AppliedPredictiveModeling)
set.seed(3433)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]
```

Create a training data set consisting of only the predictors with variable names beginning with IL and the diagnosis. Build two predictive models, one using the predictors as they are and one using PCA with principal components explaining 80% of the variance in the predictors. Use method="glm" in the train function.

What is the accuracy of each method in the test set? Which is more accurate?


```r
str(training)
```

```
## 'data.frame':	251 obs. of  131 variables:
##  $ diagnosis                       : Factor w/ 2 levels "Impaired","Control": 2 2 2 2 1 2 2 2 1 1 ...
##  $ ACE_CD143_Angiotensin_Converti  : num  2.003 1.521 1.681 2.401 0.431 ...
##  $ ACTH_Adrenocorticotropic_Hormon : num  -1.386 -1.715 -1.609 -0.968 -1.273 ...
##  $ AXL                             : num  1.098 -0.145 0.683 0.191 -0.222 ...
##  $ Adiponectin                     : num  -5.36 -5.81 -5.12 -4.78 -5.22 ...
##  $ Alpha_1_Antichymotrypsin        : num  1.74 1.19 1.28 2.13 1.31 ...
##  $ Alpha_1_Antitrypsin             : num  -12.6 -13.6 -15.5 -11.1 -12.1 ...
##  $ Alpha_1_Microglobulin           : num  -2.58 -2.88 -3.17 -2.34 -2.55 ...
##  $ Alpha_2_Macroglobulin           : num  -72.7 -136.5 -98.4 -144.9 -154.6 ...
##  $ Angiopoietin_2_ANG_2            : num  1.0647 0.8329 0.9163 0.9555 -0.0513 ...
##  $ Angiotensinogen                 : num  2.51 1.98 2.38 2.86 2.52 ...
##  $ Apolipoprotein_A_IV             : num  -1.43 -1.66 -2.12 -1.17 -1.39 ...
##  $ Apolipoprotein_A1               : num  -7.4 -7.68 -8.05 -6.73 -7.4 ...
##  $ Apolipoprotein_A2               : num  -0.2614 -0.6539 -1.2379 0.0953 -0.2744 ...
##  $ Apolipoprotein_B                : num  -4.62 -3.98 -6.52 -3.38 -2.96 ...
##  $ Apolipoprotein_CI               : num  -1.273 -1.715 -1.966 -0.755 -1.661 ...
##  $ Apolipoprotein_CIII             : num  -2.31 -2.75 -3 -1.51 -2.31 ...
##  $ Apolipoprotein_D                : num  2.08 1.34 1.44 1.63 1.92 ...
##  $ Apolipoprotein_E                : num  3.755 2.753 2.371 3.067 0.591 ...
##  $ Apolipoprotein_H                : num  -0.1573 -0.3448 -0.5317 0.6626 0.0972 ...
##  $ B_Lymphocyte_Chemoattractant_BL : num  2.3 1.67 1.98 2.3 2.48 ...
##  $ BMP_6                           : num  -2.2 -2.06 -1.98 -1.24 -1.88 ...
##  $ Beta_2_Microglobulin            : num  0.693 0.336 0.642 0.336 -0.545 ...
##  $ Betacellulin                    : int  34 49 52 67 51 41 42 58 32 43 ...
##  $ C_Reactive_Protein              : num  -4.07 -8.05 -6.21 -4.34 -7.56 ...
##  $ CD40                            : num  -0.796 -1.242 -1.124 -0.924 -1.784 ...
##  $ CD5L                            : num  0.0953 0.0953 -0.3285 0.3633 0.4055 ...
##  $ Calbindin                       : num  33.2 22.2 23.5 21.8 13.2 ...
##  $ Calcitonin                      : num  1.386 2.116 -0.151 1.308 1.629 ...
##  $ CgA                             : num  398 348 334 443 138 ...
##  $ Clusterin_Apo_J                 : num  3.56 2.77 2.83 3.04 2.56 ...
##  $ Complement_3                    : num  -10.4 -16.1 -13.2 -12.8 -12 ...
##  $ Complement_Factor_H             : num  3.57 4.47 3.1 7.25 3.57 ...
##  $ Connective_Tissue_Growth_Factor : num  0.531 0.642 0.531 0.916 0.993 ...
##  $ Cortisol                        : num  10 10 14 11 13 4.9 13 12 6.8 12 ...
##  $ Creatine_Kinase_MB              : num  -1.71 -1.38 -1.65 -1.63 -1.67 ...
##  $ Cystatin_C                      : num  9.04 8.95 9.58 8.98 7.84 ...
##  $ EGF_R                           : num  -0.135 -0.733 -0.422 -0.621 -1.111 ...
##  $ EN_RAGE                         : num  -3.69 -4.76 -2.94 -2.36 -3.44 ...
##  $ ENA_78                          : num  -1.35 -1.39 -1.37 -1.34 -1.36 ...
##  $ Eotaxin_3                       : int  53 62 44 64 57 64 64 64 82 73 ...
##  $ FAS                             : num  -0.0834 -0.6349 -0.478 -0.1278 -0.3285 ...
##  $ FSH_Follicle_Stimulation_Hormon : num  -0.652 -1.563 -0.59 -0.976 -1.683 ...
##  $ Fas_Ligand                      : num  3.1 1.36 2.54 4.04 2.41 ...
##  $ Fatty_Acid_Binding_Protein      : num  2.521 0.906 0.624 2.635 0.624 ...
##  $ Ferritin                        : num  3.33 3.18 3.14 2.69 1.85 ...
##  $ Fetuin_A                        : num  1.281 1.411 0.742 2.152 1.482 ...
##  $ Fibrinogen                      : num  -7.04 -7.2 -7.8 -6.98 -6.44 ...
##  $ GRO_alpha                       : num  1.38 1.41 1.37 1.4 1.4 ...
##  $ Gamma_Interferon_induced_Monokin: num  2.95 2.76 2.89 2.85 2.82 ...
##  $ Glutathione_S_Transferase_alpha : num  1.064 0.889 0.708 1.236 1.154 ...
##  $ HB_EGF                          : num  6.56 7.75 5.95 7.25 6.41 ...
##  $ HCC_4                           : num  -3.04 -3.65 -3.82 -3.15 -3.08 ...
##  $ Hepatocyte_Growth_Factor_HGF    : num  0.5878 0.0953 0.4055 0.5306 0.0953 ...
##  $ I_309                           : num  3.43 2.4 3.37 3.76 2.71 ...
##  $ ICAM_1                          : num  -0.1908 -0.462 -0.8573 0.0972 -0.9351 ...
##  $ IGF_BP_2                        : num  5.61 5.18 5.42 5.42 5.06 ...
##  $ IL_11                           : num  5.12 4.67 6.22 7.07 6.1 ...
##  $ IL_13                           : num  1.28 1.27 1.31 1.31 1.28 ...
##  $ IL_16                           : num  4.19 2.62 2.44 4.74 2.67 ...
##  $ IL_17E                          : num  5.73 4.15 4.7 4.2 3.64 ...
##  $ IL_1alpha                       : num  -6.57 -8.18 -7.6 -6.94 -8.18 ...
##  $ IL_3                            : num  -3.24 -4.65 -4.27 -3 -3.86 ...
##  $ IL_4                            : num  2.48 1.82 1.48 2.71 1.21 ...
##  $ IL_5                            : num  1.099 -0.248 0.788 1.163 -0.4 ...
##  $ IL_6                            : num  0.269 0.186 -0.371 -0.072 0.186 ...
##  $ IL_6_Receptor                   : num  0.6428 0.0967 0.5752 0.0967 -0.5173 ...
##  $ IL_7                            : num  4.81 1.01 2.34 4.29 2.78 ...
##  $ IL_8                            : num  1.71 1.69 1.72 1.76 1.71 ...
##  $ IP_10_Inducible_Protein_10      : num  6.24 5.05 5.6 6.37 5.48 ...
##  $ IgA                             : num  -6.81 -6.32 -7.62 -4.65 -5.81 ...
##  $ Insulin                         : num  -0.626 -1.447 -1.485 -0.3 -1.341 ...
##  $ Kidney_Injury_Molecule_1_KIM_1  : num  -1.2 -1.19 -1.23 -1.16 -1.12 ...
##  $ LOX_1                           : num  1.705 1.163 1.224 1.361 0.642 ...
##  $ Leptin                          : num  -1.529 -1.662 -1.269 -0.915 -1.361 ...
##  $ Lipoprotein_a                   : num  -4.27 -5.84 -4.99 -2.94 -4.51 ...
##  $ MCP_1                           : num  6.74 6.77 6.78 6.72 6.54 ...
##  $ MCP_2                           : num  1.981 0.401 1.981 2.221 2.334 ...
##  $ MIF                             : num  -1.24 -2.3 -1.66 -1.9 -2.04 ...
##  $ MIP_1alpha                      : num  4.97 4.05 4.93 6.45 4.6 ...
##  $ MIP_1beta                       : num  3.26 2.4 3.22 3.53 2.89 ...
##  $ MMP_2                           : num  4.48 2.87 2.97 3.69 2.92 ...
##  $ MMP_3                           : num  -2.21 -2.3 -1.77 -1.56 -3.04 ...
##  $ MMP10                           : num  -3.27 -2.73 -4.07 -2.62 -3.32 ...
##  $ MMP7                            : num  -3.774 -4.03 -6.856 -0.222 -1.922 ...
##  $ Myoglobin                       : num  -1.9 -1.39 -1.14 -1.77 -1.14 ...
##  $ NT_proBNP                       : num  4.55 4.25 4.11 4.47 4.19 ...
##  $ NrCAM                           : num  5 4.74 4.97 5.2 3.26 ...
##  $ Osteopontin                     : num  5.36 5.02 5.77 5.69 4.74 ...
##  $ PAI_1                           : num  1.004 0.438 0 0.252 0.438 ...
##  $ PAPP_A                          : num  -2.9 -2.94 -2.79 -2.94 -2.94 ...
##  $ PLGF                            : num  4.44 4.51 3.43 4.8 4.39 ...
##  $ PYY                             : num  3.22 2.89 2.83 3.66 3.33 ...
##  $ Pancreatic_polypeptide          : num  0.579 -0.892 -0.821 0.262 -0.478 ...
##  $ Prolactin                       : num  0 -0.1393 -0.0408 0.1823 -0.1508 ...
##  $ Prostatic_Acid_Phosphatase      : num  -1.62 -1.64 -1.74 -1.7 -1.76 ...
##  $ Protein_S                       : num  -1.78 -2.26 -2.7 -1.66 -2.36 ...
##  $ Pulmonary_and_Activation_Regulat: num  -0.844 -1.661 -1.109 -0.562 -1.171 ...
##  $ RANTES                          : num  -6.21 -6.65 -5.99 -6.32 -6.5 ...
##   [list output truncated]
```

```r
names(training)
```

```
##   [1] "diagnosis"                        "ACE_CD143_Angiotensin_Converti"  
##   [3] "ACTH_Adrenocorticotropic_Hormon"  "AXL"                             
##   [5] "Adiponectin"                      "Alpha_1_Antichymotrypsin"        
##   [7] "Alpha_1_Antitrypsin"              "Alpha_1_Microglobulin"           
##   [9] "Alpha_2_Macroglobulin"            "Angiopoietin_2_ANG_2"            
##  [11] "Angiotensinogen"                  "Apolipoprotein_A_IV"             
##  [13] "Apolipoprotein_A1"                "Apolipoprotein_A2"               
##  [15] "Apolipoprotein_B"                 "Apolipoprotein_CI"               
##  [17] "Apolipoprotein_CIII"              "Apolipoprotein_D"                
##  [19] "Apolipoprotein_E"                 "Apolipoprotein_H"                
##  [21] "B_Lymphocyte_Chemoattractant_BL"  "BMP_6"                           
##  [23] "Beta_2_Microglobulin"             "Betacellulin"                    
##  [25] "C_Reactive_Protein"               "CD40"                            
##  [27] "CD5L"                             "Calbindin"                       
##  [29] "Calcitonin"                       "CgA"                             
##  [31] "Clusterin_Apo_J"                  "Complement_3"                    
##  [33] "Complement_Factor_H"              "Connective_Tissue_Growth_Factor" 
##  [35] "Cortisol"                         "Creatine_Kinase_MB"              
##  [37] "Cystatin_C"                       "EGF_R"                           
##  [39] "EN_RAGE"                          "ENA_78"                          
##  [41] "Eotaxin_3"                        "FAS"                             
##  [43] "FSH_Follicle_Stimulation_Hormon"  "Fas_Ligand"                      
##  [45] "Fatty_Acid_Binding_Protein"       "Ferritin"                        
##  [47] "Fetuin_A"                         "Fibrinogen"                      
##  [49] "GRO_alpha"                        "Gamma_Interferon_induced_Monokin"
##  [51] "Glutathione_S_Transferase_alpha"  "HB_EGF"                          
##  [53] "HCC_4"                            "Hepatocyte_Growth_Factor_HGF"    
##  [55] "I_309"                            "ICAM_1"                          
##  [57] "IGF_BP_2"                         "IL_11"                           
##  [59] "IL_13"                            "IL_16"                           
##  [61] "IL_17E"                           "IL_1alpha"                       
##  [63] "IL_3"                             "IL_4"                            
##  [65] "IL_5"                             "IL_6"                            
##  [67] "IL_6_Receptor"                    "IL_7"                            
##  [69] "IL_8"                             "IP_10_Inducible_Protein_10"      
##  [71] "IgA"                              "Insulin"                         
##  [73] "Kidney_Injury_Molecule_1_KIM_1"   "LOX_1"                           
##  [75] "Leptin"                           "Lipoprotein_a"                   
##  [77] "MCP_1"                            "MCP_2"                           
##  [79] "MIF"                              "MIP_1alpha"                      
##  [81] "MIP_1beta"                        "MMP_2"                           
##  [83] "MMP_3"                            "MMP10"                           
##  [85] "MMP7"                             "Myoglobin"                       
##  [87] "NT_proBNP"                        "NrCAM"                           
##  [89] "Osteopontin"                      "PAI_1"                           
##  [91] "PAPP_A"                           "PLGF"                            
##  [93] "PYY"                              "Pancreatic_polypeptide"          
##  [95] "Prolactin"                        "Prostatic_Acid_Phosphatase"      
##  [97] "Protein_S"                        "Pulmonary_and_Activation_Regulat"
##  [99] "RANTES"                           "Resistin"                        
## [101] "S100b"                            "SGOT"                            
## [103] "SHBG"                             "SOD"                             
## [105] "Serum_Amyloid_P"                  "Sortilin"                        
## [107] "Stem_Cell_Factor"                 "TGF_alpha"                       
## [109] "TIMP_1"                           "TNF_RII"                         
## [111] "TRAIL_R3"                         "TTR_prealbumin"                  
## [113] "Tamm_Horsfall_Protein_THP"        "Thrombomodulin"                  
## [115] "Thrombopoietin"                   "Thymus_Expressed_Chemokine_TECK" 
## [117] "Thyroid_Stimulating_Hormone"      "Thyroxine_Binding_Globulin"      
## [119] "Tissue_Factor"                    "Transferrin"                     
## [121] "Trefoil_Factor_3_TFF3"            "VCAM_1"                          
## [123] "VEGF"                             "Vitronectin"                     
## [125] "von_Willebrand_Factor"            "age"                             
## [127] "tau"                              "p_tau"                           
## [129] "Ab_42"                            "male"                            
## [131] "Genotype"
```

```r
training_subset <- training %>% 
                        select(starts_with("IL") | "diagnosis")

testing_subset <- testing %>% 
                        select(starts_with("IL") | "diagnosis")

names(training_subset)
```

```
##  [1] "IL_11"         "IL_13"         "IL_16"         "IL_17E"       
##  [5] "IL_1alpha"     "IL_3"          "IL_4"          "IL_5"         
##  [9] "IL_6"          "IL_6_Receptor" "IL_7"          "IL_8"         
## [13] "diagnosis"
```

```r
names(testing_subset)
```

```
##  [1] "IL_11"         "IL_13"         "IL_16"         "IL_17E"       
##  [5] "IL_1alpha"     "IL_3"          "IL_4"          "IL_5"         
##  [9] "IL_6"          "IL_6_Receptor" "IL_7"          "IL_8"         
## [13] "diagnosis"
```

```r
# model Non-PCA
mod1 <- train(
            diagnosis ~ .,
            data = training_subset,
            method = "glm"
            )

pred1 <- predict(mod1, testing_subset)

result1 <- confusionMatrix(pred1, testing_subset$diagnosis)

# model PCA
mod2 <- train(
            diagnosis ~ .,
            data = training_subset,
            trControl = trainControl(preProcOptions = list(thresh = 0.8)),
            preProcess = "pca",
            method = "glm"
            )

pred2 <- predict(mod2, testing_subset)

result2 <- confusionMatrix(pred2, testing_subset$diagnosis)

result1
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction Impaired Control
##   Impaired        4       2
##   Control        18      58
##                                           
##                Accuracy : 0.7561          
##                  95% CI : (0.6488, 0.8442)
##     No Information Rate : 0.7317          
##     P-Value [Acc > NIR] : 0.3606488       
##                                           
##                   Kappa : 0.1929          
##                                           
##  Mcnemar's Test P-Value : 0.0007962       
##                                           
##             Sensitivity : 0.18182         
##             Specificity : 0.96667         
##          Pos Pred Value : 0.66667         
##          Neg Pred Value : 0.76316         
##              Prevalence : 0.26829         
##          Detection Rate : 0.04878         
##    Detection Prevalence : 0.07317         
##       Balanced Accuracy : 0.57424         
##                                           
##        'Positive' Class : Impaired        
## 
```

```r
result2
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction Impaired Control
##   Impaired        1       2
##   Control        21      58
##                                           
##                Accuracy : 0.7195          
##                  95% CI : (0.6094, 0.8132)
##     No Information Rate : 0.7317          
##     P-Value [Acc > NIR] : 0.6517805       
##                                           
##                   Kappa : 0.0167          
##                                           
##  Mcnemar's Test P-Value : 0.0001746       
##                                           
##             Sensitivity : 0.04545         
##             Specificity : 0.96667         
##          Pos Pred Value : 0.33333         
##          Neg Pred Value : 0.73418         
##              Prevalence : 0.26829         
##          Detection Rate : 0.01220         
##    Detection Prevalence : 0.03659         
##       Balanced Accuracy : 0.50606         
##                                           
##        'Positive' Class : Impaired        
## 
```

## A5

I can't make it work. this exercise will be lacking. :/
