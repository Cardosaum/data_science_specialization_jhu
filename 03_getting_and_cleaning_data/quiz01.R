# Quiz, week 1
## Let's set the cwd correctly first. (Using as reference the directory containing the .Rproj file)
setwd("./03_getting_and_cleaning_data")

## Now we load the libraries
library(data.table, quietly = TRUE)
library(tidyverse, quietly = TRUE)
library(xml2, quietly = TRUE)
library(readxl, quietly = TRUE)

## helper functions
### check if file exists. if don't, download it
fileDownload <- function(fileUrl, fileName){
    if (!file.exists(fileName)){
        download.file(fileUrl, fileName, "curl")
    }
}

# Q1 
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv", "./data/us_communities.csv")

## Load data
data <- read_csv("./data/us_communities.csv")
moreThan1Mi <- data %>% drop_na(VAL) %>% filter(VAL >= 24) %>% nrow()
print(moreThan1Mi)

# Q2
## Just read the code book

# Q3 
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx", "./data/natural_gas_aquisition.xlsx")

## Load data
dat <- read_excel("./data/natural_gas_aquisition.xlsx", range = cell_limits(ul = c(18, 7), lr = c(23, 15)))
print(sum(dat$Zip * dat$Ext, na.rm = TRUE))

# Q4
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml", "./data/baltimore_restaurants.xml")

## Load data
baltimoreRestaurants <- read_xml("./data/baltimore_restaurants.xml")
baltimoreRestaurants %>% xml_find_all("//zipcode[text()=21231]") %>% 
                         length() %>% 
                         print()

# Q5
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv", "./data/idaho.csv")

## Load data
DT <- fread("./data/idaho.csv")
benchmark <- microbenchmark(DT[ , mean(pwgtp15), by=SEX], tapply(DT$pwgtp15, DT$SEX, mean), times = 800)
print(benchmark) # the answer in Q5 is the first expression, but microbenchmark show the opposite...






