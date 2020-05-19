# Matheus, 2020

best <- function(state, outcome) {
    library(tidyverse)
    
    # first, we read the data
    data <- read_csv("outcome-of-care-measures.csv")
    hospitals <- read_csv("hospital-data.csv")
    class(data[[11]]) <- "numeric"
    class(data[[17]]) <- "numeric"
    class(data[[23]]) <- "numeric"
    
    colnames(data)[11] <- "heart attack"
    colnames(data)[17] <- "heart failure"
    colnames(data)[23] <- "pneumonia"
    # now, we check if `state` and `outcome` are valid
    if ( !( state %in% unique(hospitals[["State"]]))) {
        stop("invalid state")
    }
    if ( !( outcome %in% c("heart attack", "heart failure", "pneumonia"))) {
        stop("invalid outcome")
    }
    
    # finaly, we return the hospital name in `state` with
    # the lowest outcome
    
    result <- data %>% filter(State == state)
    result <- result[order(result[[outcome]], na.last = TRUE), ]
    result <- result[1, ]
    result[["Hospital Name"]]
    
}
