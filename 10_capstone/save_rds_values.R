source("ngrams_suggest.R")

all_ngrams <- read_ngrams(list.files(pattern = "ngrams_.*filtered.*en.*csv$", recursive = T))
all_ngrams %<>%
    mutate(xgram = str_extract(file, "\\dgrams")) %>%
    mutate(xgram = str_extract(xgram, "\\d"))
all_ngrams
write_rds(all_ngrams, "data/all_ngrams.rds")

suggest_this <- list.files(pattern = "ngrams_.*filtered.*en.*csv$", recursive = T)
suggest_this <- suggest_this[str_detect(suggest_this, "1")][1]
suggest_this <- read_csv(suggest_this, n_max = 5)
suggest_this
write_rds(suggest_this, "data/suggest_this.rds")

smp <- get_search_df(all_ngrams, "jsdlkafjçkldsafjlsdfçajdklfjlsadçfjsdlkfjaçlkdfjsçalfdkj lsad fkjlasdfja sdljf lasdf")
compute_score(smp)
