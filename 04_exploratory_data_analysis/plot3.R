# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds")

# plot 3
png("plot3.png")
total_per_year <- NEI %>% filter(fips == "24510") %>%  group_by(year, type) %>% summarise(total = sum(Emissions))
ggplot(total_per_year, aes(year, total, colour = type)) + geom_point() + geom_line() + labs(title = "Change in PM particle in Baltimore", subtitle = "Particles are subseted by 'type'")
dev.off()
