library(shiny)
library(tidyverse)
library(magrittr)
library(forcats)
library(ggthemes)
library(ggdark)
source("ngrams_suggest.R")


# Define UI for app that draws a histogram ----
ui <- navbarPage(
    
    # set theme
    theme = shinythemes::shinytheme("darkly"),

    "WordPredictor",
    tabPanel("Application",
        # Sidebar layout with input and output definitions ----
        sidebarLayout(
    
            # Sidebar panel for inputs ----
            sidebarPanel(
                h4("Quick Tip:"),
                helpText("Just write in the box below the sentece you'd like the model to complete"),
                helpText("You can also change the number of ngrams to use in the predictor model."),
                helpText("(generally, higher ngram values produce better predictions - at the cost of being more time consuming.)"),
                helpText("One interesting thing you can also do is to choose between show stopwords or not."),
                helpText("Hope you like!"),
                br(),
                sliderInput(inputId = "q_ngrams",
                            label = "How many ngrams to select?",
                            min = 2,
                            max = 7,
                            value = 4),
                textInput(inputId = "itext",
                          label = "Write a sentence",
                          value = "What a great"),
                selectInput("showStopwords",
                            "Do you want to consider stopwords as valid suggestions?",
                            c(
                                "Yes, show me stopwords" = "yes",
                                "No, don't show me annoying stopwords" = "no"
                            ),
                            "yes")
            ),
    
            # Main panel for displaying outputs ----
            mainPanel(
                h1("Word Predictor Model's results"),
                br(),
                h2("Table with predictions and associated score"),
                dataTableOutput("prediction"),
                br(),
                h2("Bar plot of top 5 predictions"),
                plotOutput("bar")
            )
        )
    ),
    tabPanel("About",
             h1("Word Predictor Engine"),
             br(),
             h3("Who made this app?"),
             tags$div(
                 tags$span("Well, if you are interested in figure it out,"),
                 tags$a(href = "https://github.com/cardosaum", "check my github!"),
                 tags$span(":)")
             ),
             h3("Why you made this app?"),
             tags$div(
                 tags$span("I published this app as the final project for the"),
                 tags$a(href = "https://www.coursera.org/specializations/jhu-data-science", "Data Science Specialization by John Hopkins University."),
                 tags$br(),
                 tags$span("The idea of this project was to create a predictive typing engine able to suggest, with high accuracy, the next word intended to be written by the user. (well stablished products with this same objective are "),
                 tags$a(href = "https://www.wikiwand.com/en/Gboard", "Gboard"),
                 tags$span("and "),
                 tags$a(href = "https://www.wikiwand.com/en/Microsoft_SwiftKey", "SwiftKey"),
                 tags$span(", for example).")
                    ),
             h3("Here can I find the source code for this app?"),
             tags$div(
                 tags$span("All the code I wrote for this app can be found at the"),
                 tags$a(href = "https://github.com/Cardosaum/data_science_specialization_jhu/tree/master/10_capstone", "project's repository in github.")
             ),
             h3("Oh... I think you answered all my questions. Thank you and nice project!"),
             tags$span("Thanks! Glad you liked!")
                 
             )
)


# Define server logic required to draw a histogram ----
server <- function(input, output) {
    observeEvent({
        input$q_ngrams
        input$itext
        input$showStopwords
        1}, {
            
        output$qn <- renderDataTable({input$q_ngrams}) 
        
        write("should be updating...", "./ham", append = T)
        suggestions_df    <- get_search_df(all_ngrams, input$itext)
        suggestions_score <- compute_score(suggestions_df)
        if (input$showStopwords == "no") {
            suggestions_score %<>% 
                filter(!(character %in% stopwords::data_stopwords_stopwordsiso$en))
        }
        
        suggestions_score %<>% 
            arrange(desc(score))
        
        output$prediction <- renderDataTable(
            options = list(pageLength = 5), {
            suggestions_score
        })
        
        suggestions_score %>% 
            arrange(desc(score)) %>% 
            head(5) %>% 
            mutate(character = fct_reorder(character, score)) -> df_top
        
        output$bar <- renderPlot({
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
                ) +
                dark_theme_gray() +
                theme(
                    plot.background = element_rect(fill = "#222222"),
                    panel.background = element_blank(),
                    legend.background = element_blank(),
                    panel.grid.major = element_line(color = "grey30"),
                    panel.grid.minor = element_line(color = "grey30"))
        })
    })
}

shinyApp(ui = ui, server = server)
