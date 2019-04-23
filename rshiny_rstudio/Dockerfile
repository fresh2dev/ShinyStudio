FROM rocker/verse:latest

# essential vars
ENV DISABLE_AUTH true
ENV R_LIBS_USER /r-libs
ENV APPLICATION_LOGS_TO_STDOUT false
# reduce time spent waiting for libs to compile.
# http://www.rexamine.com/2015/07/speeding-up-r-package-installation-process/
ENV MAKE 'make -j 8'

# add shiny immediately and expose port 3838.
RUN export ADD=shiny && bash /etc/cont-init.d/add
EXPOSE 3838

# create shared /r-libs directory and ensure it's writeable by all.
RUN sudo mkdir /r-libs && \
	echo ".libPaths( c( '/r-libs', .libPaths() ) )" >> /usr/local/lib/R/etc/Rprofile.site

# install R packages
# rmarkdown 1.12 does not display floating TOC; downgrade to 1.11.
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rmarkdown/rmarkdown_1.11.tar.gz', repos=NULL)" && \
    R -e "install.packages(c('reticulate', 'png', 'DBI', 'odbc', 'shinydashboard', 'flexdashboard', 'shinycssloaders', 'DT', 'visNetwork', 'networkD3'))" && \
    chmod -R 777 /r-libs

# setup python
ENV VIRTUAL_ENV /pyenv

RUN apt-get update && \
    apt-get install -y python3-pip python3-venv libpython-dev libpython3-dev python-dev python3-dev && \
    python3 -m venv "${VIRTUAL_ENV}" && \
    chmod -R 777 "${VIRTUAL_ENV}" && \
    "${VIRTUAL_ENV}/bin/activate"

# install python packages
ENV PATH "${VIRTUAL_ENV}/bin:${PATH}"
RUN echo "export PATH=\"${VIRTUAL_ENV}/bin:\${PATH}\"" >> /etc/profile && \
    pip install --upgrade pip && \
    pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org \
        wheel Cython numpy matplotlib pandas tqdm ezpq paramiko requests

# install pwsh
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux
RUN apt-get install -y curl gnupg apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list && \
    apt-get update && \
    apt-get install -y powershell

# install cloudera odbc driver
RUN wget https://downloads.cloudera.com/connectors/ClouderaImpala_ODBC_2.6.2.1002/Debian/clouderaimpalaodbc_2.6.2.1002-2_amd64.deb -O clouderaimpalaodbc_amd64.deb && \
	dpkg -i clouderaimpalaodbc_amd64.deb

# copy odbc driver and dns configs.
COPY config/odbc/odbcinst.ini /etc/odbcinst.ini
COPY config/odbc/odbc.ini /etc/odbc.ini

# copy custom run commands.
COPY config/run /etc/services.d/rstudio/run
# custom configs
COPY config/rserver.conf /etc/rstudio/rserver_custom.conf
COPY config/shiny-server.conf /etc/shiny-server/shiny-server.conf

# copy custom start command and make it executable.
COPY config/start.sh /start.sh
RUN sudo chmod +x /start.sh

# reset MAKE
ENV MAKE 'make'

CMD [ "/start.sh" ]
