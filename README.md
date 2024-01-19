# DVHZ3-SOCS0100-Assessment2

> Second summative assignment for the SOCS0100 module, including an interactive dashboard with three visualizations

## What the project include

1.  an `interactive_report.qmd` and an `interactive_report` file, which include the three interactive visualisations
2.  an app called `interactive visualisations`, which features the same visualisation but in app format
3.  `140123original_IFPI_data.csv` : data statically scrapped from IFPI report
4.  `140123tophits.csv`: data collected using spotify API consists of 50 top hits songs from 6 countries on 14 Jan 2023
5.  `references.bib` : reference list for academic papers cited
6.  `Assignment coversheet_SRI.docx`: the coversheet for the assignment
7.  an html report similar to the one in qmd
8.  `data_scraping.R` a separate R script for data scraping (included in the report & the app)
9.  `data_wrangling.R` a separate R script for data wrangling (included in the report & the app)

## what this project does

This project includes code snippets that performs automatic data collection from `Spotify API` and `International Federation of the Phonographic Industry (IFPI)` data. It then produces three interactive visualisation:

1\. scatter plot of **different audio features** and **popularity**

2\. radar graph of the **avearage audio features** of tophits in six countries

3\. dot plot of the **size** and **level of digitization** of countries with the largest music markets form 2011-2017

## How to start the project

### Opening report

1.  open the `interactive_report.qmd` with R-studio
2.  remove the `#` before `if (!require("groundhog")) {install.packages("groundhog")}` and `groundhog.library(pkgs, "2024-01-04")` in the `setup` code chunk located at the top of the document to install packages necessary for running the document
3.  render the `.qmd` document in r-studio

> For other files in this project, follow a similar procedure as the set-up code is always located at the top of the code and follows the same format using `groundhog` for reproducibility

### Opening app

1.  find the `app` in `interactive visualisations,` open it with `r-studio`
2.  remove \# before the set up chunk
3.  Run app

## Reproducibility

-   the packages used will be loaded via `groundhog` as they are available on 04-Jan-2023

-   the scraped data are stored in their original form on 14-Jan-2023 in this file

-   the radar chart and the scatter plot are downloadable for future reference

-   Both the app and the interactive report runs on `version 2023.09.0+463 (2023.09.0+463)` of R-studio.

## Contribution

The tophits data were automatically collected using the [Spotify API](https://developer.spotify.com/documentation/web-api) and the [spotifyr](https://www.rcharlie.com/spotifyr/) package

The IFPI annual data were statically scrapped from [this wikipedia page](https://en.wikipedia.org/wiki/List_of_largest_recorded_music_markets)

I consulted the following tutorials for API and static data collection

1.  [Exploring the Spotify API with R](https://msmith7161.github.io/what-is-speechiness/) [Using the spotify API in R](https://youtu.be/utWH3c8a3dA?si=lOha5QRRoZL4nN8u)

2.  [in-class material](https://brksnmz.github.io/SOCS0100/2023/weeks/week07/page7.html) for static web scraping.

For the plots, I consulted the following tutorials

1.  [scatter plot](https://youtu.be/SnCi0s0e4Io?si=t17n-ViTAuvjNmRv) of market size

2.  [radar chart](https://r-graph-gallery.com/143-spider-chart-with-saveral-individuals.html) of the popular audio features in different country

3.  [plotly scatter plot](https://plotly.com/r/figure-labels/) for audio features of top songs

For the download feature, I used the code provided by [this solution](https://community.rstudio.com/t/shiny-download-ggplot/90532/2).

I followed [the official shiny gallery](https://shiny.posit.co/r/gallery/application-layout/navbar-example/) for the Navbar layout in the app.

I critically engaged with [ChatGPT](https://chat.openai.com/) for code refinement and correction throughout the process.
