# complete.R
# Matheus

complete <- function(directory, id = 1:332) {
    library(tidyverse)
    data <- tibble(id = numeric(), nobs = numeric())
    files <- list.files(path = directory, pattern = ".csv$", full.names = TRUE)
    for(i in id) {
        if(i %in% seq_along(files)){
            t <- read_csv(files[i], col_types = cols(Date = col_date(), sulfate = col_double(), nitrate = col_double(), ID = col_integer()))
            data <- data %>%
                add_row(id = t[["ID"]][1], nobs = sum(complete.cases(t)))
        }
    }
    data
}
