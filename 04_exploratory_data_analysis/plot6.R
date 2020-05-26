# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds") %>% as_tibble()

# plot 6
png("plot6.png")
motor_vehicle <- SCC %>% filter(str_detect(Short.Name, "Veh"))
baltimore_losAngeles <- semi_join(NEI, motor_vehicle, by = "SCC") %>% filter(fips == "24510" | fips == "06037") %>% mutate(fips = factor(fips)) %>% group_by(fips, year) %>% summarise(total = sum(Emissions))
ggplot(baltimore_losAngeles, aes(year, total, colour = fips)) + geom_point() + geom_line() + labs(title = "PM particles", subtitle = "Particules emitted by Motor Vehicles", color = "City") + scale_color_hue(labels = c("Los Angeles", "Baltimore"))
dev.off()
