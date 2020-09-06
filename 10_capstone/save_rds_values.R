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

smp <- get_search_df(all_ngrams, "does the data")
ham <- compute_score(smp)

ham %>% 
    filter(!(character %in% stopwords::data_stopwords_stopwordsiso$en))

ham %>% 
    head(5) %>% 
    mutate(character = fct_reorder(character, score)) -> df_top

df_top %>% 
    ggplot() +
    geom_bar(aes(character, score, fill = character), stat = "identity") +
    coord_flip(ylim = c(min(df_top$score), max(df_top$score))) +
    guides(fill = guide_legend(reverse = T, title = "Word")) +
    labs(
        title = "Bar plot of top 5 suggested words",
        y = "Score",
        x = "Suggested Word",
        caption = "Note that Score axis has dynamic range."
    )

library(wordcloud)


wordcloud(words = ham$character,
          freq  = ham$score,
          # min.freq = 0.52,
          max.words = 200,
          # random.order = F,
          # rot.per = 0.95,
          colors = brewer.pal(6, "Dark2"))

smp %>% 
    mutate(character = stri_trim(str_extract(character, "\\s?[\\w']+$"))) %>% 
    group_by(character) %>% 
    summarise(total = sum(total)) %>% 
    arrange(desc(total)) -> bar 

bar %>% 
    head(200) -> barr

wordcloud(words = bar$character,
          freq  = bar$total,
          max.words = 200,
          random.order = F,
          colors = brewer.pal(6, "Dark2"))


suggestions_df    <- get_search_df(all_ngrams, "you are")
source("ngrams_suggest.R")
suggestions_score <- compute_score(suggestions_df)
suggestions_score %>% 
    # filter(!(character %in% stopwords::data_stopwords_stopwordsiso$en)) %>%
    # filter((character %in% stopwords::data_stopwords_stopwordsiso$en)) %>% 
    arrange(desc(score))

suggestions_df %>% 
    arrange(desc(xgram, total))

suggestions_score %>% 
    filter(!(character %in% stopwords::data_stopwords_stopwordsiso$en))
df_top
