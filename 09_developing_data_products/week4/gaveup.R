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
library(glue)
brazil <- st_read("data/gis-dataset-brasil/uf/geojson/uf.json")
brazil %<>% 
    mutate(
        NOME_UF = gsub("\xe1", "á", NOME_UF),
        NOME_UF = gsub("\xed", "í", NOME_UF),
        NOME_UF = gsub("\xf4", "ô", NOME_UF),
        NOME_UF = gsub("\xe3", "ã", NOME_UF))
enem_top <- read_rds("data/enem_top_summarise.rds")
enem_raças <- enem_top$TP_COR_RACA %>% attr("levels")
enem_top %>%
    inner_join(brazil, by = c("SG_UF_RESIDENCIA" = "UF_05")) %>%
    st_as_sf() -> enem_top_geo
enem_colnames <- colnames(enem_top_geo)[1:12]


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
                                    "Humanas" = "NU_NOTA_CH")),
            selectInput(inputId = "raça_selected",
                        label = "Select an Etny",
                        choices = enem_raças)

        ),

        # Main panel for displaying outputs ----
        mainPanel(

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

    output$materia_selecionada <- renderText({input$tipo_nota})
    
    output$map <- renderTmap({
        tm_shape(nz) +
            tm_fill() +
            tm_borders()
    })
    
    output$map <- renderTmap({
        enem_top_geo %>% 
            filter(TP_COR_RACA == "Branca") %>%
            tm_shape() +
            tm_polygons("NU_NOTA_MT",
                        popup.vars = enem_colnames,
                        title = glue("Nota para pessoas de raça:<br /><i>Branca</i>")) +
        	tm_text("SG_UF_RESIDENCIA")
    })
    
    observe({
        enem_top_geo %>% 
            filter(TP_COR_RACA == input$raça_selected) -> newData
        tmapProxy("map", {
            tm_remove_layer(401) +
            tm_shape(newData) +
            tm_polygons(input$tipo_nota,
                        popup.vars = enem_colnames,
                        id = input$raça_selected,
                        title = glue("Nota para pessoas de raça:<br /><i>{input$raça_selected}</i>")) +
        	tm_text("SG_UF_RESIDENCIA")
            })
    })

}

shinyApp(ui = ui, server = server)
