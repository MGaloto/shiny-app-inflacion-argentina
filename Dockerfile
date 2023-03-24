FROM rocker/shiny:4.1.3
RUN install2.r rsconnect highcharter XML rlist flexdashboard tidyverse shiny readxl RColorBrewer httr lubridate writexl
WORKDIR /home/shinyarg
COPY MacroTrends.Rmd MacroTrends.Rmd
COPY deploy.R deploy.R
COPY www/styles.css www/styles.css
COPY downloadData.R downloadData.R
CMD Rscript deploy.R