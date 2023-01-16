FROM rocker/r-ver:4.2.0

MAINTAINER Emmanuel Blondel "eblondel.pro@gmail.com"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    texlive-xetex \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-formats-extra \
    libssl-dev \
    libxml2-dev \
    libv8-dev \
    libsodium-dev \
    libsecret-1-dev \
    librdf0-dev \
    git
    
#redland install (for atom4R/zen4R)
RUN install2.r --error --skipinstalled --ncpus -1 redland
RUN apt_install \
    libcurl4-openssl-dev \
    libgit2-dev \
    libxslt-dev \
    librdf0 \
    redland-utils \
    rasqal-utils \
    raptor2-utils
    
#geospatial libraries install
RUN /rocker_scripts/install_geospatial.sh

# install R core package dependencies
RUN install2.r --error --skipinstalled --ncpus -1 httpuv
RUN R -e "install.packages(c('remotes','jsonlite','yaml'), repos='https://cran.r-project.org/')"
# clone app
RUN git -C /root/ clone https://github.com/eblondel/geoflow-shiny.git && echo "OK!"
RUN ln -s /root/geoflow-shiny /srv/geoflow-shiny
# install R app package dependencies
RUN R -e "source('./srv/geoflow-shiny/install.R')"

#etc dirs (for config)
RUN mkdir -p /etc/geoflow-shiny/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/srv/geoflow-shiny',port=3838,host='0.0.0.0')"]
