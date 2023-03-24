FROM rocker/shiny:4.2.1
COPY install.R install.R
RUN Rscript install.R
WORKDIR /home/shinyarg
COPY MacroTrends.Rmd MacroTrends.Rmd
COPY deploy.R deploy.R
COPY downloadData.R downloadData.R
CMD Rscript deploy.R