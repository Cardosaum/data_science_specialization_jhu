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

# Define UI for app that draws a histogram ----
ui <- fluidPage(

    # App title ----
    titlePanel("Notas Enem"),

    # Sidebar layout with input and output definitions ----
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(

            selectInput(inputId = "tipo_nota",
                        label = "Selecione qual nota mostrar",
                        choices = c(
                                    "Redação" = "NU_NOTA_REDACAO",
                                    "Matemática" = "NU_NOTA_MT",
                                    "Linguaguens" = "NU_NOTA_LC",
                                    "Natureza" = "NU_NOTA_CN",
                                    "Humanas" = "NU_NOTA_CH"))

        ),

        # Main panel for displaying outputs ----
        mainPanel(

            plotOutput(outputId = "enem_plot"),
            br(),
            textOutput("materia_selecionada"),
            br(),
            tmapOutput("map"),
            br(),
            br()
            
            

        )
    )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

    enem_df <- read_rds("data/os_bons.rds")
    
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

    output$enem_plot <- renderPlot({
        enem_df %>%
            ggplot() +
            geom_histogram(aes(.data[[input$tipo_nota]], fill = me))
    })

    output$materia_selecionada <- renderText({input$tipo_nota})
    
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
