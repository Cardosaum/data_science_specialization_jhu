# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds")

# plot 2
png("plot2.png")
total_per_year <- NEI %>% filter(fips == "24510") %>%  group_by(year) %>% summarise(total = sum(Emissions))
plot(total_per_year$year, total_per_year$total, xlab = "Year", ylab = "Total PM - Baltimore", main = "Change in PM particles in Baltimore")
dev.off()
