# 1.setup----
rm(list = ls())
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
  "shinyanimate"
)
# groundhog.library(pkgs, "2024-01-04")


# 2. static scraping annual IFPI data from 2011 to 2017----
# If the website allows scraping, then proceed scraping, else print error message
if(paths_allowed("https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets")){
  # function that enables parsing multiple tables automatically on wikipedia
  parse_annual_data_tables <- function(x){
    url <- "https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets"
    parsed <- read_html(url)
    annual_data_tables <- html_element(parsed, xpath =
   paste0('//*[@id="mw-content-text"]/div[1]/table[',x,']')) #the only changing part is the number of the table, which is arranged in yearly order
    IFPI_data <- html_table(annual_data_tables)   
    return(IFPI_data)}
  original_IFPI_data <- map_df(6:12, parse_annual_data_tables)
} else {print("Sorry, the page is not scrapable now.There may be a change in the website settings.")
}
  
#export the data to csv format
write_csv(original_IFPI_data,"140123original_IFPI_data.csv") 
  
  
  
  
#The scraping code chunks are disabled as they require private API key to run. Data wrangling and visualization will be based on data scrapped on 14 Jan 2023.


#3.Using spotifyr to access API and scrape top hits from top 6 countries----
#creating a variable called access token
Sys.setenv(SPOTIFY_CLIENT_ID = 'paste your own client id here')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'paste your own client secret here')
access_token <- get_spotify_access_token()

#scraping top hits
UKtophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbLnolsZ8PSNw',authorization = get_spotify_access_token())

KRtophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbNxXF4SkHj9F',authorization = get_spotify_access_token())

UStophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbLRQDuF5jeBp',authorization = get_spotify_access_token())

JPtophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbKXQ4mDTEBXq',authorization = get_spotify_access_token())

DEtophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbJiZcmkrIHGU',authorization = get_spotify_access_token())

FRtophits<-get_playlist_audio_features('paste your own spotify user id here','37i9dQZEVXbIPWwFssbupI',authorization = get_spotify_access_token())

#bind the top hits from 6 countries into one dataframe called tophits
tophits<-bind_rows(UKtophits,KRtophits,UStophits,JPtophits,DEtophits,FRtophits)

#exporting tophits as scraped on 14 Jan 2024 for future reproducibility
write_csv(tophits,"140123tophits.csv")
  