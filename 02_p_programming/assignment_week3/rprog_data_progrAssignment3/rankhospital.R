# Matheus, 2020

rankhospital <- function(state, outcome, num = "best") {
    
    # sanity check;
    # is outcome valid?
    if ( !(outcome %in% c("heart attack", "heart failure", "pneumonia"))) { stop("invalid outcome")}
    
    # first, we read the data
    data <- read_csv("outcome-of-care-measures.csv")
    hospitals <- read_csv("hospital-data.csv")
    
    class(data[[11]]) <- "numeric"
    class(data[[17]]) <- "numeric"
    class(data[[23]]) <- "numeric"
    
    colnames(data)[11] <- "heart attack"
    colnames(data)[17] <- "heart failure"
    colnames(data)[23] <- "pneumonia"
    
    # sanity check; 
    # is `state` actualy in this dataset?
    if (!(state %in% unique(data$State))) { stop("invalid state") }
    
    
    # select only the subset of the data that contain `state`, ordered by `outcome`
    df <- data %>% filter(State == state) %>% arrange(.[[outcome]]) %>% drop_na(outcome)
    
    # change keywords for actual numbers
    if (num == "best") { num <- 1 }
    if (num == "worst") { num <- nrow(df)}
    
    # sanity check;
    # does `df` has dataset `num` rows?
    # if not, return `NA`
    if (nrow(df) < num) { return(NA) }
    
    # get Xth value, ordered alphabeticaly
    df <- df[order(df[[outcome]], df[["Hospital Name"]]), ][num, ][["Hospital Name"]]
    df
}

