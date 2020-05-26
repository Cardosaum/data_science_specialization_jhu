# Quiz, week 3
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
agricultureLogical <- (acs$ACR == 3 & acs$AGS == 6)
print(which(agricultureLogical)[1:3])

# Q2
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg", "./data/jeff.jpg")
jeff <- jpeg::readJPEG("./data/jeff.jpg", native = TRUE)
print(quantile(jeff, c(0.3, 0.8)))

# Q3
## Download file
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv", "./data/gdp.csv")
fileDownload("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv", "./data/data_EDSTATS_Country.csv")
gdp <- read_csv("./data/gdp.csv", skip = 3, skip_empty_rows = TRUE)
edu <- read_csv("./data/data_EDSTATS_Country.csv")
gdp_edu_length <- intersect(gdp$X1, edu$CountryCode) %>% length()
gdp_edu_13th <- intersect(gdp$X1, edu$CountryCode)[13]
cat(gdp_edu_length, gdp_edu_13th)

# Q4
gdp_hi <- edu %>% filter(.[["Income Group"]] == "High income: nonOECD" | .[["Income Group"]] == "High income: OECD") %>% group_by(.[["Income Group"]])
gdp <- gdp %>% rename(CountryCode = X1, rk = contains("rank"), gdp = contains("dollar")) %>% select(CountryCode, rk, gdp) %>% drop_na(CountryCode)
gdp_final <- inner_join(gdp_hi, gdp)
gdp_final <-  gdp_final %>% rename(incomeGroup = contains("group"))
gdp_final[["gdp"]] <- str_replace_all(gdp_final$gdp, ",", "") %>% str_replace_all("[.]", "")
gdp_final <-  gdp_final %>% mutate_at("gdp", as.numeric)
gdp_final <-  gdp_final %>% mutate_at("rk", as.numeric)
print(gdp_final %>% summarise(mean = mean(rk, na.rm = T)))

# Q5
