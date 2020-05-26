# Quiz, week 4
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
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv", "./data/us_communities.csv")
acs <- read_csv("./data/us_communities.csv")
print(strsplit(names(acs), "wgtp")[123])

# Q2
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv", "./data/gdp.csv")
gdp <- read_csv("./data/gdp.csv")
gdp[["X5"]] <- gsub(",", "", gdp$X5 ) %>% gsub("\\.\\.", "", .) %>%  sapply(as.numeric)
gdp <- gdp %>% drop_na(X5)
print(mean(gdp[["X5"]], na.rm = TRUE)) # this code diverges from all the question options (code wrong?)

# Q3
print(grep("^United", gdp$X4, value = TRUE))

# Q4
## Downlaod file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv", "./data/gdp.csv")
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv", "./data/data_EDSTATS_Country.csv")

gdp <- read_csv("./data/gdp.csv")
edu <- read_csv("./data/data_EDSTATS_Country.csv")
edu <- edu %>% rename(notes = contains("Special Notes"))
print(edu %>% filter(grepl("Fiscal.*June", notes)) %>% select("CountryCode", "notes"))

# Q5
library(quantmod)
amzn <- getSymbols("AMZN",auto.assign=FALSE)
sampleTimes <- index(amzn)
days_2012 <- subset(sampleTimes, sampleTimes >= "2012-01-01" & sampleTimes < "2013-01-01" ) %>% length()
mondays_2012 <- subset(sampleTimes, sampleTimes >= "2012-01-01" & sampleTimes < "2013-01-01" ) %>% weekdays()    
mondays_2012 <- grepl("Monday", mondays_2012) %>% sum()
cat(days_2012, mondays_2012)


