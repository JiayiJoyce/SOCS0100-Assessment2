# 1.setup----
rm(list = ls())
if (!require("groundhog")) {
  install.packages("groundhog")
}
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
groundhog.library(pkgs, "2024-01-04")



# 2.importing the original scrapped data-----
original_IFPI_data <- read_csv("140123original_IFPI_data.csv")
original_tophits <- read_csv("140123tophits.csv")

#3. Wrangling the IFPI data----
#adding year column to the IFPI data. The year was not incuded when scraping as they were not part of the table on the webpage
year_len <- 11
original_IFPI_data$year <- rep(seq(2017, 1 + nrow(original_IFPI_data) %/% year_len), each = year_len, length.out = nrow(original_IFPI_data))

#removing `% Change` column, which is all NA
wrangled_IFPI_data <- original_IFPI_data %>%
  select(!`% Change`)

#removing "," from the `Retail valueUS$ (millions)` column to convert it to numeric value
wrangled_IFPI_data$`Retail valueUS$ (millions)` <- gsub(',', '', wrangled_IFPI_data$`Retail valueUS$ (millions)`)

wrangled_IFPI_data$`Retail valueUS$ (millions)` <- as.numeric(wrangled_IFPI_data$`Retail valueUS$ (millions)`)

#tidying observations
#fix NA
remove_percentage_sign_fix_missing <- function(x){
  x <- gsub('%', '', x)
  x[x == "n/a"] <- NA
  x
}
#apply the remove_percentage_sign function to the following columns: Physical, Digital, Performance Rights, Synchronization 
wrangled_IFPI_data[,c(4:7)] <- purrr::map_df(wrangled_IFPI_data[,c(4:7)], remove_percentage_sign_fix_missing)

# cleaning names
#use janitor to clean the column names
wrangled_IFPI_data <- janitor::clean_names(wrangled_IFPI_data)
#standardize the country names using countrycode package
wrangled_IFPI_data$market <- ifelse(
  grepl("[A-Za-z]", wrangled_IFPI_data$market),  # Check if there are letters
  countrycode(wrangled_IFPI_data$market, origin = 'country.name', destination = 'country.name.en'),
  countrycode(wrangled_IFPI_data$market, origin = 'iso2c', destination = 'country.name.en')
)
# subsetting global data (NA after standardinsing country names) to a new dataset
global_IFPI_data <- wrangled_IFPI_data %>%
  filter(is.na(market))%>%
  select(year,retail_value_us_millions)
#change the retail_value_us_millions column to numeric
global_IFPI_data$retail_value_us_millions <- as.numeric(global_IFPI_data$retail_value_us_millions)
#change the year column to character
global_IFPI_data$year <- as.character(global_IFPI_data$year)
# turning character to numerics for data visualisation
#change column 4-7 to numeric, and then adding 'percentage' to the end of column 4-7
wrangled_IFPI_data[,c(4:7)] <- purrr::map_df(wrangled_IFPI_data[,c(4:7)], as.numeric)
colnames(wrangled_IFPI_data)[4:7] <- paste(colnames(wrangled_IFPI_data)[4:7],' percentage')
#remove the NA rows (global data is already subsetted)
wrangled_IFPI_data <- wrangled_IFPI_data[!is.na(wrangled_IFPI_data$market),]



#4. Wrangling the tophits data-----
wrangled_tophits <- original_tophits %>%
  select(playlist_name, danceability, energy, key, loudness,speechiness, acousticness, instrumentalness, liveness, valence, tempo, track.explicit, track.popularity, track.name)%>%
  rename(country = playlist_name)#rename the playlist_name column to country

#Removing the "Top 50 -  "from the country column
wrangled_tophits$country <- gsub("Top 50 - ", "", wrangled_tophits$country)
#standardize the country names using countrycode package
wrangled_tophits$country <- ifelse(
  grepl("[A-Za-z]", wrangled_tophits$country),  # Check if there are letters
  countrycode(wrangled_tophits$country, origin = 'country.name', destination = 'country.name.en'),
  countrycode(wrangled_tophits$country, origin = 'iso2c', destination = 'country.name.en')
)

