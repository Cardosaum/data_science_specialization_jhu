library(tidyverse)
library(stringi)
library(glue)
library(magrittr)

clean_string <- function(input_text) {
    output_text <- str_squish(str_remove_all(str_to_lower(input_text), "[^\\sa-z']"))
    output_text <- str_split(output_text, "\\s")[[1]]
    output_text <- str_c(output_text[!(output_text %in% c(""))], collapse = " ")
    output_text
}

ngram_text <- function(input_text, x) {
    str_c(str_remove_all(tail(stri_split_boundaries(clean_string(input_text))[[1]], n = x), pattern = " "), collapse = " ")
}

get_ngrams <- function(input_text, max_ngrams = 4) {
    if (max_ngrams == "max_possible") {max_ngrams <- hmn(input_text)}
    for (i in 2:max_ngrams) {
        text_to_search <- ngram_text(input_text, i - 1)
        write_file(glue("$character =~ \"^{text_to_search}\" "), "aff.mlr")
        # print(i)
        print(text_to_search)
        if (!exists("suggestions")) {
            # print("NO")
            suggestions <- mlr_parse(mlr_search(i), character(0), i, text_to_search)
        } else {
            # print("YES")
            suggestions %<>% mlr_parse(mlr_search(i), i, text_to_search)
    }
    }
    suggestions
}

mlr_parse <- function(df, search_result, i, text_to_search) {
    if ((length(search_result) > 0) && (!is.character(df))) {
        df %<>%
            full_join(read_csv(search_result) %>%
                          mutate(ngram = i,
                                 character = str_replace(character, glue("^{text_to_search}\\w*\\s*"), "")))
    } else if ((is.character(df)) && (length(df) > 0)) {
        # print("first successfull search")
        df <- read_csv(df) %>%
                mutate(ngram = i,
                       character = str_replace(character, glue("^{text_to_search}\\w*\\s*"), ""))
    } else {
        # print("search was not successfull")
    }
    df
}

mlr_search <- function(ngram, n = 30) {
    result <- system(glue("mlr --csv filter -f aff.mlr data/Coursera-SwiftKey/final/en_US/ngrams_filtered_{ngram}grams_count_en_US.blogs.csv"), intern = T)
    result
}

hmn <- function(input_text) {
    # find "How Many Ngrams" to use in search
    str_count(clean_string(input_text), " ") + 1
}

rank_suggestions <- function(suggestions) {
    if (!is.data.frame(suggestions)) {
        print("The input data is not a dataframe!")
        return(character(0))
    }

    final_result <- suggestions %>%
                        mutate(score = (((1/ngram^2)^-1) * count)) %>%
                        group_by(character) %>%
                        summarise(total_score = sum(score)) %>%
                        mutate(total_score = total_score/sum(total_score)) %>%
                        arrange(desc(total_score))
    final_result
}

ngram_pipeline <- function(input_text, filter_stopwords = TRUE) {
    out <- rank_suggestions(get_ngrams(input_text))
    if (!is.data.frame(out)) {return(out)}
    stopwords::data_stopwords_stopwordsiso$en

    if (filter_stopwords) {
        out %<>%
            filter(!(character %in% stopwords::data_stopwords_stopwordsiso$en))
    }
    out
}
