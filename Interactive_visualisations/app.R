# 1.setup----
# rm(list = ls())
# if (!require("groundhog")) {
#   install.packages("groundhog")
# }
pkgs <- c(
  "spotifyr", #wrapper for spotify API
  "purrr", #for static data scraping
  "xml2",
  "rvest",
  "robotstxt",
  "tidyverse",#for data wrangling
  "dplyr",
  "countrycode",#for data visualisation
  "plotly",
  "tibble",
  "ggplot2",
  "janitor",
  "gifski",
  "kableExtra",
  "fmsb",
  "gganimate",
  "shinyanimate",
  "shiny",
  "shinythemes",
  "DT"
)
# groundhog.library(pkgs, "2024-01-04")

# 2. data wrangling tophits----
original_tophits <- read_csv("140123tophits.csv")

wrangled_tophits <- original_tophits %>%
  select(playlist_name, danceability, energy, key, loudness,speechiness, acousticness, instrumentalness, liveness, valence, tempo, track.explicit, track.popularity, track.name)%>%
  rename(country = playlist_name)#rename the playlist_name column to country

#Remove the "Top 50 -  "from the country column
wrangled_tophits$country <- gsub("Top 50 - ", "", wrangled_tophits$country)
#standardize the country names using countrycode package
wrangled_tophits$country <- ifelse(
  grepl("[A-Za-z]", wrangled_tophits$country),  # Check if there are letters
  countrycode(wrangled_tophits$country, origin = 'country.name', destination = 'country.name.en'),
  countrycode(wrangled_tophits$country, origin = 'iso2c', destination = 'country.name.en')
)
# 3. data wrangling IFPI---- 
original_IFPI_data <- read_csv("140123original_IFPI_data.csv")
#adding year column 
year_len <- 11
original_IFPI_data$year <- rep(seq(2017, 1 + nrow(original_IFPI_data) %/% year_len), each = year_len, length.out = nrow(original_IFPI_data))
#exporting IFPI data as scraped on 14 Jan 2024 for reproducibility
write_csv(original_IFPI_data,"140123Original_IFPI_data.csv")

#remove `% Change` column, which is all NA
wrangled_IFPI_data <- original_IFPI_data %>%
  select(!`% Change`)

#removing "," from the `Retail valueUS$ (millions)` column to convert it to numeric value
wrangled_IFPI_data$`Retail valueUS$ (millions)` <- gsub(',', '', wrangled_IFPI_data$`Retail valueUS$ (millions)`)

#writing a function to remove % from observations and fix missing values by turning n/a to NA
remove_percentage_sign_fix_missing <- function(x){
  x <- gsub('%', '', x)
  x[x == "n/a"] <- NA
  x
}
#apply the remove_percentage_sign function to the following columns: Physical, Digital, Performance Rights, Synchronization 
wrangled_IFPI_data[,c(4:7)] <- purrr::map_df(wrangled_IFPI_data[,c(4:7)], remove_percentage_sign_fix_missing)

#change column 4-7 to numeric
wrangled_IFPI_data[,c(4:7)] <- purrr::map_df(wrangled_IFPI_data[,c(4:7)], as.numeric)

#change the column name by adding 'percentage' to the end of column 4-7
colnames(wrangled_IFPI_data)[4:7] <- paste(colnames(wrangled_IFPI_data)[4:7],' percentage')
#use janitor to clean the column names
wrangled_IFPI_data <- janitor::clean_names(wrangled_IFPI_data)

##standardize the country names using countrycode package
wrangled_IFPI_data$market <- ifelse(
  grepl("[A-Za-z]", wrangled_IFPI_data$market),  # Check if there are letters
  countrycode(wrangled_IFPI_data$market, origin = 'country.name', destination = 'country.name.en'),
  countrycode(wrangled_IFPI_data$market, origin = 'iso2c', destination = 'country.name.en')
)
#make retail_value_us_millions column numeric
wrangled_IFPI_data$retail_value_us_millions <- as.numeric(wrangled_IFPI_data$retail_value_us_millions)
#remove the rows with NA in market column
wrangled_IFPI_data <- wrangled_IFPI_data[!is.na(wrangled_IFPI_data$market),]

# remove NA rows in market column and subsetting the data to a new dataframe called global_IFPI_data
global_IFPI_data <- wrangled_IFPI_data %>%
  filter(is.na(market))%>%
  select(year,retail_value_us_millions)

#change the retail_value_us_millions column to numeric
global_IFPI_data$retail_value_us_millions <- as.numeric(global_IFPI_data$retail_value_us_millions)

global_IFPI_data$year <- as.numeric(global_IFPI_data$year)




# 4.UI ----

ui <- fluidPage(
  theme = shinytheme("cyborg"),

  navbarPage("Global Music Market: Trends and audio features",
             
             navbarMenu("3 Visualisations",
                        tabPanel("1. Audio feature and popularity",
                                 sidebarLayout(
                                   sidebarPanel(
                                     radioButtons("country_buttons", label = h3("Select country to view audio features"),
                                                  choices = unique(wrangled_tophits$country),
                                                  selected = "France"),
                                     
                                     selectInput("Yvar", label = h3("Select variable for y-axis"), 
                                                 choices = names(wrangled_tophits)[c(2, 3, 6,9,10)], 
                                                 selected = 1)
                                   ),
                                   mainPanel(
                                     plotlyOutput('audio_features')
                                   )
                                 )
                        ),
                        tabPanel("2. Average audio features",
                                 sidebarLayout(
                                   sidebarPanel(
                                     selectInput("radar_country", label = h3("Select a country to view mean audio features"), 
                                                 choices = unique(wrangled_tophits$country), 
                                                 selected = "Japan")
                                   ),
                                   mainPanel(
                                     plotOutput('radar_chart'),
                                     downloadButton("downloadRadar", "Download Radar Chart for your choosen country")
                                   )
                                 )
                        ),
                        tabPanel("3. Global music markets",
                                 sidebarLayout(
                                   sidebarPanel(
                                     sliderInput("yearslider", label = h3("Select year"), min = 2011, 
                                                 max = 2017, value = 2011,round = TRUE,sep = "",animate = TRUE)
                                   ),
                                   mainPanel(
                                     plotOutput('musicmarket')
                                   )
                                 )
                        )
             ),
             
             tabPanel("Data overview",
                      verbatimTextOutput('summary1'),
                      br(),
                      verbatimTextOutput("summary2")
             )
  )
)

# 2.server----
server <- function(input, output,session) {
  
  
  
  
  output$musicmarket <- renderPlot({
    
    IFPI_by_year <- wrangled_IFPI_data %>%
      filter(!is.na(market)) %>%
      filter(year == input$yearslider) 
    
    IFPI_graph= IFPI_by_year%>%
      ggplot(aes(x=physical_percentage, 
                 y=digital_percentage,
                 color=market,
                 size=retail_value_us_millions))+
      geom_point()+
      labs(title="3.Global Music Market from 2011 to 2017",
           x="Physical Percentage",
           y="Digital Percentage",
           size="Total retail Value in US$ millions")+
      scale_x_continuous(limits = c(0, 100)) +
      scale_y_continuous(limits = c(0, 100))+theme_minimal()
    IFPI_graph
  })
  
  
  
  
  output$radar_chart <- renderPlot({
    
    # some data wrangling to calculate the means
    radar_uk_tophits <- wrangled_tophits %>%
      filter(country == input$radar_country) %>%
      select(danceability, energy, liveness, valence, acousticness)
    
    radar_uk_tophits_mean <- radar_uk_tophits %>%
      summarise_all(mean)
    
    # Add min and max for radar plot
    radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(1))
    radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(0))
    
    # Move the third row to the first row - so that max and min are in the front, ready for plotting radar chart
    radar_uk_tophits_mean <- radar_uk_tophits_mean[c(3, 2, 1),]
    
    
    colors_fill <- c(scales::alpha("orchid", 0.1))
    colors_line <- c(scales::alpha("orchid4", 0.5))
    
    
    radarchart(
      radar_uk_tophits_mean,
      seg = 5,axistype = 1,
      pcol = colors_fill, pfcol = colors_line, plwd = 4, plty = 1,cglcol = "grey", cglty = 1, axislabcol = "hotpink", caxislabels = seq(0, 1, 0.1), cglwd = 1,vlcex = 0.8,
      title=paste("2.Characteristic of tophits in different country")
    )
    
  })
  
  
  radarchart4d <- reactive({
    
    # some data wrangling to calculate the means
    radar_uk_tophits <- wrangled_tophits %>%
      filter(country == input$radar_country) %>%
      select(danceability, energy, liveness, valence, acousticness)
    
    radar_uk_tophits_mean <- radar_uk_tophits %>%
      summarise_all(mean)
    
    # Add min and max for radar plot
    radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(1))
    radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(0))
    
    # Move the third row to the first row - so that max and min are in the front, ready for plotting radar chart
    radar_uk_tophits_mean <- radar_uk_tophits_mean[c(3, 2, 1),]
    
    
    colors_fill <- c(scales::alpha("orchid", 0.1))
    colors_line <- c(scales::alpha("orchid4", 0.5))
    
    
    radarchart(
      radar_uk_tophits_mean,
      seg = 5,axistype = 1,
      pcol = colors_fill, pfcol = colors_line, plwd = 4, plty = 1,cglcol = "grey", cglty = 1, axislabcol = "hotpink", caxislabels = seq(0, 1, 0.1), cglwd = 1,vlcex = 0.8,
      title=paste("2.Characteristic of tophits in different country")
    )
    
  })
  
  # this part is refined by chatGPT. My original code was base on https://community.rstudio.com/t/shiny-download-ggplot/90532/2 which did not ran successfully the first few times. 
  output$downloadRadar <- downloadHandler(
    filename = function() {
      paste("radar_chart_", input$radar_country, ".png", sep = "")
    },
    content = function(file) {
      # Save the radar chart as a PNG file
      png(file)
      print(radarchart4d())  # Redraw the radar chart
      dev.off()
    }
  )
  
  output$summary1 <- renderPrint({
    summary(wrangled_IFPI_data)
  })
  output$summary2 <- renderPrint({
    summary(wrangled_tophits)
  })
  
tophits_choosen <- reactive({
    wrangled_tophits %>%
      filter(country == input$country_buttons) %>%
      mutate(explicit_label = ifelse(track.explicit, "explicit", "non-explicit"))
  })

output$audio_features <- renderPlotly({
  p<-plot_ly(tophits_choosen(), 
        x = ~track.popularity, 
        y = ~get(input$Yvar), 
        color = ~explicit_label, 
        colors = c('orchid', 'royalblue'),text=~track.name, hoverinfo="text") %>%
  layout(title = "1.Relationship between Popularity and different audio features",
         xaxis = list(title = "popularity", range = c(50, 100)),
         yaxis = list (title = input$Yvar, range = c(0,1)))
  p
})
}

# Run the application 
shinyApp(ui = ui, server = server)
