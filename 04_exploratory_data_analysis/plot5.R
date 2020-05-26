# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds") %>% as_tibble()

# plot 5
png("plot5.png")
motor_vehicle <- SCC %>% filter(str_detect(Short.Name, "Veh")) 
baltimore <- semi_join(NEI, motor_vehicle, by = "SCC") %>% filter(fips == "24510") %>% group_by(year) %>% summarise(total = sum(Emissions)) %>% mutate(year = factor(year))
ggplot(baltimore, aes(year, total, colour = year)) + geom_point() + ggtitle("PM particles in Baltimore", "particles derived from Motor Vehicles")
dev.off()
