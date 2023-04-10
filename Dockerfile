FROM rocker/shiny:4.1.3


# Disabling the authentication step
ENV USER="rstudio"
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0", "--auth-none", "1"]

# Install jq to parse json files
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    libxml2-dev \
    zlib1g \
    g++-11 \
    libz-dev \
    freetype2-demos \
    libpng-dev \
    libtiff-dev \
    libjpeg-dev \
    make \
    fontconfig \
    libfribidi-dev \
    libharfbuzz-dev \
    libfontconfig1-dev \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# installing R packages
RUN R -e "install.packages('rsconnect')"
RUN mkdir packages
COPY install_packages.R packages/
COPY packages.json packages/
RUN Rscript packages/install_packages.R

WORKDIR /home/MacroTrends
COPY index.Rmd index.Rmd
COPY deploy.R deploy.R
COPY www/styles.css www/styles.css
COPY packages_rscript/install-dependencies.R packages_rscript/install-dependencies.R
COPY downloadData.R downloadData.R
COPY indecnacional.xlsx indecnacional.xlsx
CMD Rscript deploy.R