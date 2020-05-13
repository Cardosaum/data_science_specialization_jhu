# pollutantmean.R
# Matheus - 2020

pollutantmean <- function(directory, pollutant, id = 1:332) {
    library(tidyverse)
    files <- list.files(path = directory, pattern = ".csv$", full.names = TRUE)
    data <- dplyr::tibble()
    for(i in seq_along(files)) {
        if (i %in% id){
            t <- read_csv(files[i])
            data <- rbind(data, t)
        }
    }
    p <- data[[pollutant]]
    mean(p, na.rm = TRUE)
}
