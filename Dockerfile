FROM rocker/shiny:4.2.1

# Instalar paquete remotes para controlar las versiones de otros paquetes
RUN R -e 'install.packages("remotes", repos="http://cran.rstudio.com")'

# install needed R packages
RUN R -e "install.packages('highcharter', repos='http://cran.rstudio.com/')"

COPY install.R install.R
RUN Rscript install.R
WORKDIR /home/shinyarg
COPY MacroTrends.Rmd MacroTrends.Rmd
COPY deploy.R deploy.R
COPY downloadData.R downloadData.R
CMD Rscript deploy.R