
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
  "fmsb"
)

if (!require("groundhog")) {
  install.packages("groundhog")
}
groundhog.library(pkgs, "2024-01-04")

global <- read_csv("/Users/chenjiayi/Desktop/Computational/DVHZ3-SOCS0100-Assessment2/1.global_IFPI_data.csv")
IFPI <- read_csv("/Users/chenjiayi/Desktop/Computational/DVHZ3-SOCS0100-Assessment2/2.wrangled_IFPI_data.csv")
wrangled_tophits <- read_csv("/Users/chenjiayi/Desktop/Computational/DVHZ3-SOCS0100-Assessment2/3.wrangled_tophits.csv")




#coutry selector input

# filter spotify data by where country is united kingdom----
tophits_uk <- tophits %>%
  filter(country == "Japan")%>%
  mutate(explicit_label = ifelse(track.explicit, "explicit", "non-explicit"))


plot_ly(tophits_uk, 
        x = ~track.popularity, 
        y = ~danceability, 
        color = ~explicit_label, 
        colors = c('orchid', 'royalblue'),text=~track.name, hoverinfo="text") %>%
  layout(title = "Relationship between Popularity and Danceability",
         xaxis = list(title = "popularity"),
         yaxis = list (title = "danceability"))

# write a histogram based on global, where y axis is the value of music industry, x axis is the year using ggplot2

#year slider input
IFPI_by_year <- IFPI %>%
  filter(!is.na(market)) %>%
  filter(year == "2016") 

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


IFPI_graph.animation=IFPI_graph+transition_time(year)+labs(subtitle="Year: {frame_time}")+shadow_wake(wake_length = 0.2)

animate(IFPI_graph.animation, renderer = gifski_renderer(),fps=15,duration= 5)

# From now on I will plot a radar chart----

#radar radio input
#select country=United Kingdom from the tophits
radar_uk_tophits <- tophits %>%
  filter(country == "Germany")%>%
  select(danceability,energy,liveness,valence,acousticness)

#calculate the mean of each variable in radar_uk_tophits, turn them into a list
radar_uk_tophits_mean <- radar_uk_tophits %>%
  summarise_all(mean)

#add a row of 0 called  min to the rader_uk_tophits_mean dataframe
radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(1))
radar_uk_tophits_mean <- rbind(radar_uk_tophits_mean, rep(0))

#move the third row to the first row- so that max and min are in the front, ready for plotting radar chart
radar_uk_tophits_mean <- radar_uk_tophits_mean[c(3,2,1),]

#define colours
colors_fill <- c(scales::alpha("orchid", 0.1))
colors_line <- c(scales::alpha("orchid4", 0.5))

# plot with default options:
radarchart( radar_uk_tophits_mean  , seg = 5,
 axistype=1 , 
           #custom polygon
           pcol=colors_fill , pfcol=colors_line , plwd=4 , plty=1,
           #custom the grid
           cglcol="grey", cglty=1, axislabcol="hotpink", caxislabels=seq(0,1,0.1), cglwd=1,
           #custom labels
           vlcex=0.8 
)










