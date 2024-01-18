# this file is for data scraping and data wrangling
#Setup----
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
  "gifski"
)
#Remove # for the following 4 lines of code to install packages 
# if (!require("groundhog")) {
#   install.packages("groundhog")
# }
# groundhog.library(pkgs, "2024-01-04")


#1.1static scraping annual IFPI data from 2011 to 2017----
# If the website allows scraping, then proceed scraping, else print error message
if(paths_allowed("https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets")){
  # function that enables parsing multiple tables automatically on wikipedia
  parse_annual_data_tables <- function(x){
    url <- "https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets"
    parsed <- read_html(url)
    annual_data_tables <- html_element(parsed, xpath = paste0('//*[@id="mw-content-text"]/div[1]/table[',x,']'))
    IFPI_data <- html_table(annual_data_tables)   
    return(IFPI_data)
         }
  
  #since the table on 2011-17 data ranges from table 6 to table 12, they will be scraped and binded
  original_IFPI_data <- map_df(6:12, parse_annual_data_tables)
  } else {print("Sorry, the page is not scrapable now.There may be a change in the website settings.")
  }


#1.2data wrangling----
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

#static diagram----
IFPI_by_year <- wrangled_IFPI_data %>%
  filter(!is.na(market)) %>%
  filter(year == "2012") 

IFPI_graph= IFPI_by_year%>%
  ggplot(aes(x=physical_percentage, 
             y=digital_percentage,
             color=market,
             size=retail_value_us_millions))+
  geom_point()+
  labs(title="Global Music Market from 2011 to 2017",
       x="Physical Percentage",
       y="Digital Percentage",
       size="Total retail Value in US$ millions")+
  scale_x_continuous(limits = c(0, 100)) +
  scale_y_continuous(limits = c(0, 100))+theme_minimal()
IFPI_graph

#以下是动态图，year为整数






glimpse(wrangled_IFPI_data)

IFPI_graph= wrangled_IFPI_data%>%
  ggplot(aes(x=`physical_percentage`, y=digital_percentage,color=market,size=retail_value_us_millions))+geom_point()+labs(title="Global Music Market from 2011 to 2017",x="Physical Percentage",y="Digital Percentage",size="Total retail Value in US$ millions")


IFPI_graph.animation=IFPI_graph+transition_time(year)+labs(subtitle="Year: {frame_time}")+shadow_wake(wake_length = 0.2)

animate(IFPI_graph.animation, renderer = gifski_renderer(),fps=15,duration= 5)





#2.1Using spotifyr to access API and scrape top hits from top 6 countries----
#creating a variable called access token----
Sys.setenv(SPOTIFY_CLIENT_ID = 'paste your spotify id here')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'paste your client secret here')
access_token <- get_spotify_access_token()

#scraping top hits----
UKtophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbLnolsZ8PSNw',authorization = get_spotify_access_token())

KRtophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbNxXF4SkHj9F',authorization = get_spotify_access_token())

UStophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbLRQDuF5jeBp',authorization = get_spotify_access_token())

JPtophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbKXQ4mDTEBXq',authorization = get_spotify_access_token())

DEtophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbJiZcmkrIHGU',authorization = get_spotify_access_token())

FRtophits<-get_playlist_audio_features('paste your spotify user id here','37i9dQZEVXbIPWwFssbupI',authorization = get_spotify_access_token())


#2.2wrangling scraped tophits data----
#bind the top hits from 6 countries into one dataframe called tophits
tophits<-bind_rows(UKtophits,KRtophits,UStophits,JPtophits,DEtophits,FRtophits)
#exporting tophits as scraped on 14 Jan 2024 for future reproducibility
write_csv(tophits,"140123tophits.csv")
#remove the UKtophits, KRtophits, UStophits, JPtophits, DEtophits, FRtophits from environment
rm(UKtophits,KRtophits,UStophits,JPtophits,DEtophits,FRtophits)

#inspect the dataframe tophits
glimpse(tophits)
#select the columns that are needed for analysis
wrangled_tophits <- tophits %>%
  select(playlist_name, danceability, energy, key, loudness,speechiness, acousticness, instrumentalness, liveness, valence, tempo, track.explicit, track.popularity, track.name)%>%
  rename(country = playlist_name)#rename the playlist_name column to country

glimpse(wrangled_tophits)
#Remove the "Top 50 -  "from the country column
wrangled_tophits$country <- gsub("Top 50 - ", "", wrangled_tophits$country)
#standardize the country names using countrycode package
wrangled_tophits$country <- ifelse(
  grepl("[A-Za-z]", wrangled_tophits$country),  # Check if there are letters
  countrycode(wrangled_tophits$country, origin = 'country.name', destination = 'country.name.en'),
  countrycode(wrangled_tophits$country, origin = 'iso2c', destination = 'country.name.en')
)




