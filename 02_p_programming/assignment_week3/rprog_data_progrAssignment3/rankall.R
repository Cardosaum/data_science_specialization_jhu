# Matheus, 2020

# rankall.R
# this script contains a function called `rankall` that performs a search in the
# csv file "outcome-of-care-measures" and return a list of all the Xth hospitals
# in each US State.

rankall <- function(outcome, num = "best") {
    
    # sanity check;
    # is outcome valid?
    if ( !(tolower(outcome) %in% c("heart attack", "heart failure", "pneumonia"))){
        stop("invalid outcome")
    }
    
    # read the data
    library(tidyverse)
    data <- read_csv("outcome-of-care-measures.csv")
    
    # set colunm data type
    class(data[[11]]) <- "numeric"
    class(data[[17]]) <- "numeric"
    class(data[[23]]) <- "numeric"
    
    # set colunm name
    colnames(data)[2]  <- "hospital"
    colnames(data)[7]  <- "state"
    colnames(data)[11] <- "heart attack"
    colnames(data)[17] <- "heart failure"
    colnames(data)[23] <- "pneumonia"
    data <- data %>% 
            select(c("hospital", "state", "heart attack", "heart failure", "pneumonia")) %>% 
            group_by(state)
    data <- data %>% arrange(.[["state"]], .[[outcome]], .[["hospital"]])
    data <- data %>% drop_na(outcome)
    data <- data %>% group_split()
    
    # finaly, we loop through the dataset and pick the Nth hospital name and state
    final <- tibble(hospital = character(), state = character())
    for (df in data) {
        
        if (num == "best"){ hospital_name <- df[["hospital"]] %>% head(1) }
        else if (num == "worst"){ hospital_name <- df[["hospital"]] %>% tail(1) }
        else { hospital_name <- df[["hospital"]][num] }
        hospital_state = df[["state"]][1]
        new_row = c(hospital_name, hospital_state)
        final <- add_row(final, hospital = hospital_name, state = hospital_state)
    }
    
    final
}
