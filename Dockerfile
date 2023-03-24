FROM rocker/shiny:4.1.3


#COPY install.R install.R
#RUN Rscript install.R


# Instalar paquete remotes para controlar las versiones de otros paquetes
RUN R -e 'install.packages("remotes", repos="http://cran.rstudio.com")'

# install needed R packages
RUN R -e "install.packages('highcharter', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('XML', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rlist', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rsconnect', repos='http://cran.rstudio.com/')"

RUN R -e 'remotes::install_version(package = "tidyverse", version = "1.3.1", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "shiny", version = "1.7.1", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "flexdashboard", version = "0.5.2", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "lubridate", version = "1.7.10", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "readxl", version = "1.4.0", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "RColorBrewer", version = "1.1.2", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "httr", version = "1.4.2", dependencies = TRUE)'
RUN R -e 'remotes::install_version(package = "writexl", version = "1.4.0", dependencies = TRUE)'



WORKDIR /home/shinyarg
COPY MacroTrends.Rmd MacroTrends.Rmd
COPY deploy.R deploy.R
COPY downloadData.R downloadData.R
CMD Rscript deploy.R