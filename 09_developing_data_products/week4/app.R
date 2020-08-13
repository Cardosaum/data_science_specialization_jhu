library(shiny)
library(sf)
library(raster)
library(dplyr)
library(tidyverse)
library(spData)
library(spDataLarge)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2) # tidyverse data visualization package
library(broom)
library(magrittr)
library(forcats)
enem_df <- read_rds("data/enem.rds")
xtext <- "Mathematics"

# Define UI for app that draws a histogram ----
ui <- fluidPage(

    # App title ----
    titlePanel("Analysis of Score in Enem - Brazil's National Exam for High School Education"),

    # Sidebar layout with input and output definitions ----
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(

            selectInput(inputId = "tipo_nota",
                        label = "Choose Which Subject to Plot",
                        choices = c(
                                    "Mathematics" = "NU_NOTA_MT",
                                    "Essay" = "NU_NOTA_REDACAO",
                                    "Portuguese" = "NU_NOTA_LC",
                                    "Natural Sciences (Chemistry/Physics/Biology)" = "NU_NOTA_CN",
                                    "Human Sciences (History/Geograpy/Filosophy/Sociology)" = "NU_NOTA_CH")),
            selectInput(inputId = "wrap_var",
                        label = "Facet Plot by which variable?",
                        choices = c("School Type" = "TP_ESCOLA",
                                    "Foreing Language (English/Spanish)" = "TP_LINGUA",
                                    "Race/Ethnicity" = "TP_COR_RACA",
                                    "Marital Status" = "TP_ESTADO_CIVIL",
                                    "State" = "SG_UF_RESIDENCIA",
                                    "Age" = "NU_IDADE",
                                    "Male/Female" = "TP_SEXO")),
            selectInput(inputId = "facet_var",
                        label = "Color Plot by which variable?",
                        choices = c("Male/Female" = "TP_SEXO",
                                    "Foreing Language (English/Spanish)" = "TP_LINGUA",
                                    "Race/Ethnicity" = "TP_COR_RACA",
                                    "Marital Status" = "TP_ESTADO_CIVIL",
                                    "State" = "SG_UF_RESIDENCIA",
                                    "Age" = "NU_IDADE",
                                    "School Type" = "TP_ESCOLA"))

        ),

        # Main panel for displaying outputs ----
        mainPanel(

            plotOutput(outputId = "enem_plot"),
            br(),
            br(),
            h4("Map with number of students per State"),
            h6("Only showing those who could ingress in the Computer Science graduation course in University of São Paulo (USP) with their grades."),
            tmapOutput("map"),
            br(),
            br()
            
            

        )
    )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

    brazil <- st_read("data/gis-dataset-brasil/uf/geojson/uf.json")
    
    brazil %<>% 
        mutate(
            NOME_UF = gsub("\xe1", "á", NOME_UF),
            NOME_UF = gsub("\xed", "í", NOME_UF),
            NOME_UF = gsub("\xf4", "ô", NOME_UF),
            NOME_UF = gsub("\xe3", "ã", NOME_UF))
    
    enem_df %>% 
        group_by(SG_UF_RESIDENCIA) %>% 
        summarise("Vestibulandos" = n()) %>% 
        inner_join(brazil, by = c("SG_UF_RESIDENCIA" = "UF_05")) %>% 
        st_as_sf() %>% 
        mutate(breaks = seq(from = min(.$Vestibulandos), to = max(.$Vestibulandos), length.out = nrow(.))) %>% 
        .$breaks -> breaks_vestibulandos


    
    
    # output$materias <- c(
    #                     "Redação" = "NU_NOTA_REDACAO",
    #                     "Matemática" = "NU_NOTA_MT",
    #                     "Linguaguens" = "NU_NOTA_LC",
    #                     "Natureza" = "NU_NOTA_CN",
    #                     "Humanas" = "NU_NOTA_CH")
    # xlab_text <- observe({
    # if (input$tipo_nota == "NU_NOTA_REDACAO") {
    #     xtext <- "Essay"
    # } else if (input$tipo_nota == "NU_NOTA_MT") {
    #     xtext <- "Mathematics"
    # } else if (input$tipo_nota == "NU_NOTA_CN") {
    #     xtext <- "Natural Sciences (Chemistry/Physics/Biology)"
    # } else if (input$tipo_nota == "NU_NOTA_CH") {
    #     xtext <- "Human Sciences (History/Geograpy/Filosophy/Sociology)"
    # } else if (input$tipo_nota == "NU_NOTA_LC") {
    #     xtext <- "Portuguese"
    # } else {
    #     xtext <- "ERROR"
    # }
    #     print(xtext)
    # })
    output$enem_plot <- renderPlot({
        enem_df %>% 
            ggplot() +
            geom_histogram(aes(.data[[input$tipo_nota]], fill = .data[[input$facet_var]])) +
            facet_wrap(~ .data[[input$wrap_var]]) +
            labs(title = "Histogram of scores in Enem",
                 x = "Score (0 - 1000)",
                 caption = "Only showing the students who could ingress in Computer Science at São Paulo University (USP) using their scores.") +
            theme(legend.title = element_blank())
    })

    output$map <- renderTmap({
        enem_df %>% 
            group_by(SG_UF_RESIDENCIA) %>% 
            summarise("Vestibulandos" = n()) %>% 
            inner_join(brazil, by = c("SG_UF_RESIDENCIA" = "UF_05")) %>% 
            st_as_sf() %>% 
            mutate(breaks = seq(from = min(.$Vestibulandos), to = max(.$Vestibulandos), length.out = nrow(.))) %>% 
            tm_shape() +
            tm_polygons("Vestibulandos", legend.show = F, breaks = breaks_vestibulandos, id="Vestibulandos") 
    })

}

shinyApp(ui = ui, server = server)
