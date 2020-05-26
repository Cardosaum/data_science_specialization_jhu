# Quiz, week 2
## Let's set the cwd correctly first. (Using as reference the directory containing the .Rproj file)
setwd("./03_getting_and_cleaning_data")

## Now we load the libraries
library(data.table, quietly = TRUE)
library(tidyverse, quietly = TRUE)
library(RMariaDB, quietly = TRUE)
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
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv", "./data/american_communit_survey_quiz2.csv")
acs <- read_csv("./data/american_communit_survey_quiz2.csv")
# the package required for this question is outdated...

# Q4
## Download file
fileDownload("http://biostat.jhsph.edu/~jleek/contact.html", "./data/contact.html")
contactFile <- readLines("./data/contact.html")
numberOfLines <- contactFile[c(10, 20, 30, 100)] %>% nchar()
print(numberOfLines)

# Q5
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for", "./data/sst_data.txt")

### credit for this line: https://stackoverflow.com/questions/14383710/read-fixed-width-text-file
sstData <- read_fwf("./data/sst_data.txt", skip = 4, fwf_widths(c(12, 7, 4, 9, 4, 9, 4, 9, 4)))
sumForth <- sstData[[4]] %>% sum()
print(sumForth)
