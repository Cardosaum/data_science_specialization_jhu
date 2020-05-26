# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds")

# plot 1
total_per_year <- NEI %>% group_by(year) %>% summarise(total = sum(Emissions))
png("plot1.png")
plot(total_per_year$year, total_per_year$total, xlab = "Year", ylab = "Total PM", main = "Total PM emission in the US")
dev.off()
