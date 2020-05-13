# corr.R
# Matheus

corr <- function(directory, threshold = 0) {
    data <- complete(directory = directory)
    files <- data %>% filter(nobs > threshold)
    d <- dim(files)
    if (d[1] <= 0) {
        return(0)
    }
    
    files_selected <- files[1]
    data_files <- function() {
        for (i in files_selected) {
            filename <- sprintf("%03d.csv", i)
            path <- file.path(directory, filename)
        }
        path
    }
    
    read_this <- data_files()
    
    final_data <- vector()
    for (i in read_this) {
        data <- read_csv(i, col_types = cols(Date = col_date(), sulfate = col_double(), nitrate = col_double(), ID = col_integer())) %>% drop_na()
        data_correlation <- data %>% select(sulfate, nitrate) 
        data_correlation <- cor(data_correlation[["sulfate"]], data[["nitrate"]])
        final_data[i] <- data_correlation
    }
    final_data <- unname(final_data)
}
