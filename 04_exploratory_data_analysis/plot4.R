# matheus, 2020

# load libraries
library(tidyverse)

# download file
NEI <- readRDS("summarySCC_PM25.rds") %>% as_tibble()
SCC <- readRDS("Source_Classification_Code.rds") %>% as_tibble()

# plot 4
png("plot4.png")
coal_combustion <- SCC %>% filter(str_detect(Short.Name, "Coal")) %>% filter(str_detect(SCC.Level.One , "Combustion")) 
coal <- semi_join(NEI, coal_combustion, by = "SCC") %>% group_by(year) %>% summarise(total = sum(Emissions)) %>% mutate(year = factor(year))
ggplot(coal, aes(year, total, colour = year)) + geom_point() + labs(title = "PM particles emitted by coal combustion related sources in the US")
dev.off()
