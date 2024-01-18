#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(tidyverse)
library(dplyr)



wrangled_tophits <- read_csv("/Users/chenjiayi/Desktop/Computational/DVHZ3-SOCS0100-Assessment2/3.wrangled_tophits.csv")



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Global Music Industry value"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          radioButtons("country_buttons", label = h3("Select country to view audio features"),
                       choices = unique(wrangled_tophits$country),
                       selected = "United Kingdom")
          
        ),

        # Show a plot of the generated distribution
        mainPanel(
          plotOutput("audio_features")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$audio_features <- renderPlot({
    tophits_choosen <- wrangled_tophits %>%
      filter(country == input$country_buttons)%>%
      mutate(explicit_label = ifelse(track.explicit, "explicit", "non-explicit"))
    
    
    plot_ly(tophits_choosen, 
            x = ~track.popularity, 
            y = ~danceability, 
            color = ~explicit_label, 
            colors = c('orchid', 'royalblue'),text=~track.name, hoverinfo="text") %>%
      layout(title = "Relationship between Popularity and Danceability",
             xaxis = list(title = "popularity"),
             yaxis = list (title = "danceability"))})

    
}

# Run the application 
shinyApp(ui = ui, server = server)
