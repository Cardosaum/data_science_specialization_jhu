library(tidyverse)
library(stringi)
library(glue)
library(magrittr)

read_ngrams <- function(list_ngrams) {
    for (f in sort(list_ngrams)) {
        if (str_detect(f, "1gram")) {
            # print(glue("skipping file: {f}"))
            next
            }
        if (!exists("df_ngrams")) {
            df_ngrams <- read_csv(f, col_types = "dc") %>%
                mutate(file = f)
        } else {
            df_ngrams %<>%
                full_join(read_csv(f, col_types = "dc") %>% mutate(file = f))

        }
    }
    df_ngrams
}

input_format <- function(input_text) {
    output_text <- str_squish(str_remove_all(str_to_lower(input_text), "[^\\sa-z']"))
    output_text <- str_split(output_text, "\\s")[[1]]
    output_text <- str_c(output_text[!(output_text %in% c(""))], collapse = " ")
    output_text
}

input_length <- function(input_text) {
    length(stri_split_boundaries(input_format(input_text))[[1]])
}

ngram_text <- function(input_text, x) {
    str_c(str_remove_all(tail(stri_split_boundaries(input_format(input_text))[[1]], n = x), pattern = " "), collapse = " ")
}

search_format <- function(input_text) {glue("{input_text} ")}

get_search_df <- function(ngrams_df, input_text) {
    it <- input_format(input_text)
    how_many_loops <- min(input_length(it), 7, na.rm = T)
    for (i in seq_len(how_many_loops)) {
        stext <- search_format(ngram_text(it, i))
        if (!exists("search_df")) {
            # print(i)
            # print(stext)
            ngrams_df %>% 
                filter(xgram == (i + 1)) %>%
                filter(stri_startswith_fixed(character, stext)) %>% 
                arrange(-count) %>% 
                group_by(character) %>%
                summarise(total = sum(count),
                          xgram = xgram) %>% 
                slice_head(n = 1) %>% 
                arrange(-total) -> search_df
        } else {
            # print(i)
            # print(stext)
            ngrams_df %>% 
                filter(xgram == (i + 1)) %>%
                filter(stri_startswith_fixed(character, stext)) %>% 
                arrange(-count) %>% 
                group_by(character) %>%
                summarise(total = sum(count),
                          xgram = xgram) %>% 
                slice_head(n = 1) %>% 
                arrange(-total) %>% 
                full_join(search_df) -> search_df
        }
    }
    search_df %<>% 
        arrange(desc(xgram), desc(total)) %>% 
        ungroup() %>% 
        mutate(xgram = as.integer(xgram),
               total = as.integer(total))
    if (nrow(search_df) < 1) {
        # print("No Match found, loading default suggestion")
        search_df <- read_rds("shiny_data/suggest_this.rds") %>% 
            mutate(total = count,
                   xgram = 1)
    }
    search_df
}

compute_score <- function(ngrams_df) {
    final_df <- 
        ngrams_df %>% 
        ungroup() %>% 
        group_by(xgram) %>% 
        mutate(score = (exp(xgram) * (total / sum(total)))) %>% 
        arrange(desc(score)) %>% 
        mutate(character = str_extract(character, "\\s?[\\w']+$")) %>% 
        mutate(character = stri_trim(character)) %>% 
        group_by(character) %>% 
        summarise(
            score = sum(score),
            character = character,
            .groups = "keep") %>% 
        slice_head(n = 1) %>% 
        ungroup() %>% 
        arrange(desc(score)) %>% 
        mutate(score = (exp(score) / (exp(score) + 1)))
    final_df
}

if (!exists("all_ngrams")) {
    all_ngrams <- read_rds("shiny_data/all_ngrams.rds")
}
