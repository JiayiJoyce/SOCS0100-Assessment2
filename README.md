# DVHZ3-SOCS0100-Assessment2

> Second summative assignment for the SOCS0100 module, including an interactive dashboard with three visualizations

## What the project include
1. a `interactive_report.qmd` file, which include the three interactive visualisations
2. `140123original_IFPI_data.csv` : data statically scrapped from IFPI report
3. `140123tophits.csv`: data collected using spotify API consists of 50 top hits songs from 6 countries on 14 Jan 2023
4. `references.bib` : reference list for academic papers cited
5. `Assignment coversheet_SRI.docx`: the coversheet for the assignment


## How to start the project
1. open the `interactive_report.qmd` with R-studio
2. remove the `#` before `if (!require("groundhog")) {install.packages("groundhog")}` and `groundhog.library(pkgs, "2024-01-04")` in the `setup` code chunk located at the top of the document to install packages necessary for running the document


## Contribution
The tophits data were automatically collected using the [Spotify API](https://developer.spotify.com/documentation/web-api) and the [spotifyr](https://www.rcharlie.com/spotifyr/) package

The IFPI annual data were statically scrapped from [this wikipedia page](https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets)

I consulted the following tutorials for API and static data collection

1.  [Exploring the Spotify API with R](https://msmith7161.github.io/what-is-speechiness/) [Using the spotify API in R](https://youtu.be/utWH3c8a3dA?si=lOha5QRRoZL4nN8u)

2.   [in-class material](https://brksnmz.github.io/SOCS0100/2023/weeks/week07/page7.html) for static web scraping.

For the plots, I consulted the following tutorials

1.  [scatter plot](https://youtu.be/SnCi0s0e4Io?si=t17n-ViTAuvjNmRv) of market size

2.  [radar chart](https://r-graph-gallery.com/143-spider-chart-with-saveral-individuals.html) of the popular audio features in different country

3.  [plotly scatter plot](https://plotly.com/r/figure-labels/) for audio features of top songs

For the download feature, I used the code provided by [this solution](https://community.rstudio.com/t/shiny-download-ggplot/90532/2) 

I critically engaged with [ChatGPT](https://chat.openai.com/) for code refinement and correction throughout the process.


