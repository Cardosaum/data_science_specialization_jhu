source("suggest_ngrams.R")

q1 <- ngram_pipeline("The guy in front of me just bought a pound of bacon, a bouquet, and a case of")
q1 %>%
    filter(character %in% c("cheese", "pretzels", "soda", "beer"))
# correct: beer
q2 <- ngram_pipeline("You're the reason why I smile everyday. Can you follow me please? It would mean the")
ngram_pipeline("You're the reason why I smile everyday. Can you follow me please? It would mean the", filter_stopwords = F) %>%
    filter(character %in% c("world", "best", "most", "universe"))
q2 %>%
    filter(character %in% c("world", "best", "most", "universe"))
# correct: world
q3 <- ngram_pipeline("Hey sunshine, can you follow me and make me the")
q3 %>%
    filter(character %in% c("bluest", "smelliest", "happiest", "saddest"))
# correct: happiest
q4 <- ngram_pipeline("Very early observations on the Bills game: Offense still struggling but the")
q4 %>%
    filter(character %in% c("players", "defense", "referees", "crowd"))
# correct: defense
q5 <- ngram_pipeline("Go on a romantic date at the")
q5 %>%
    filter(character %in% c("grocery", "mall", "movies", "beach"))
# correct: beach
q6 <- ngram_pipeline("Well I'm pretty sure my granny has some old bagpipes in her garage I'll dust them off and be on my", filter_stopwords = F)
q6 %>%
    filter(character %in% c("way", "motorcycle", "horse", "phone"))
# correct: way
q7 <- ngram_pipeline("Ohhhhh #PointBreak is on tomorrow. Love that film and haven't seen it in quite some")
q7 %>%
    filter(character %in% c("thing", "weeks", "time", "years"))
# correct: time
q8 <- ngram_pipeline("After the ice bucket challenge Louis will push his long wet hair out of his eyes with his little")
q8 %>%
    filter(character %in% c("ears", "fingers", "eyes", "toes"))
# correct: fingers
q9 <- ngram_pipeline("Be grateful for the good times and keep the faith during the")
q9 %>%
    filter(character %in% c("hard", "worse", "sad", "bad"))
# correct: bad
q10 <- ngram_pipeline("If this isn't the cutest thing you've ever seen, then you must be", filter_stopwords = F)
q10 %>%
    filter(character %in% c("asleep", "insane", "insensitive", "callous"))
# correct: insane

q1 <- ngram_pipeline("When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd")
q1 %>%
    filter(character %in% c("give", "die", "eat", "sleep"))
# correct: die
q2 <- ngram_pipeline("Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his")
q2 %>%
    filter(character %in% c("spiritual", "horticultural", "marital", "financial"))
# correct: marital
q3 <- ngram_pipeline("I'd give anything to see arctic monkeys this")
q3 %>%
    filter(character %in% c("decade", "morning", "month", "weekend"))
# correct: weekend
q4 <- ngram_pipeline("Talking to your mom has the same effect as a hug and helps reduce your")
q4 %>%
    filter(character %in% c("sleepiness", "hunger", "stress", "happiness"))
# correct: stress
q5 <- ngram_pipeline("When you were in Holland you were like 1 inch away from me but you hadn't time to take a")
q5 %>%
    filter(character %in% c("minute", "look", "walk", "picture"))
# wrong: (look, picture)
q6 <- ngram_pipeline("I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the", filter_stopwords = F)
q6 %>%
    filter(character %in% c("account", "incident", "case", "matter"))
# wrong: (case)
q7 <- ngram_pipeline("I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each")
q7 %>%
    filter(character %in% c("finger", "arm", "hand", "toe"))
# correct: hand
q8 <- ngram_pipeline("Every inch of you is perfect from the bottom to the")
q8 %>%
    filter(character %in% c("middle", "center", "top", "side"))
# correct: top
q9 <- ngram_pipeline("I’m thankful my childhood was filled with imagination and bruises from playing")
q9 %>%
    filter(character %in% c("daily", "inside", "weekly", "outside"))
# correct: outside
q10 <- ngram_pipeline("I like how the same people are in almost all of Adam Sandler's", filter_stopwords = F)
q10 %>%
    filter(character %in% c("pic", "insane", "insensitive", "callous"))
# correct: movies
