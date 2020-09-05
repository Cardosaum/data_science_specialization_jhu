library(shiny)
library(tidyverse)
library(magrittr)
library(forcats)
source("suggest_ngrams.R")

# Define UI for app that draws a histogram ----
ui <- fluidPage(

    # App title ----
    titlePanel("Word Predictor"),

    # Sidebar layout with input and output definitions ----
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(
            sliderInput(inputId = "q_ngrams",
                        label = "How many ngrams to select?",
                        min = 2,
                        max = 7,
                        value = 4),
            textInput(inputId = "itext",
                      label = "Write a sentence")
        ),

        # Main panel for displaying outputs ----
        mainPanel(
            textOutput("qn"),
            dataTableOutput("prediction")
        )
    )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
    observeEvent(input$q_ngrams, {
        output$qn <- renderDataTable({input$q_ngrams}) 
    })
    
    observeEvent(input$itext, {
        output$prediction <- renderText({
            ngram_pipeline(input$itext)
        })
    })
}

shinyApp(ui = ui, server = server)
