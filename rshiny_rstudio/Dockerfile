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
RUN sudo mkdir -p /r-libs && \
	echo ".libPaths( c( '/r-libs', .libPaths() ) )" >> /usr/local/lib/R/etc/Rprofile.site

# rmarkdown 1.12 does not display floating TOC; downgrade to 1.11.
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rmarkdown/rmarkdown_1.11.tar.gz', repos=NULL)" && \
	R -e "install.packages(c('DBI', 'odbc', 'shinydashboard', 'shinycssloaders', 'DT', 'visNetwork', 'networkD3'))" && \
	chmod -R 777 /r-libs

# install cloudera odbc driver
RUN wget https://downloads.cloudera.com/connectors/ClouderaImpala_ODBC_2.6.2.1002/Debian/clouderaimpalaodbc_2.6.2.1002-2_amd64.deb -O clouderaimpalaodbc_amd64.deb && \
	dpkg -i clouderaimpalaodbc_amd64.deb

# copy odbc driver and dns configs.
COPY config/odbc/odbcinst.ini /etc/odbcinst.ini
COPY config/odbc/odbc.ini /etc/odbc.ini

# copy custom run commands.
COPY config/rserver.conf /etc/rstudio/rserver_custom.conf
COPY config/run /etc/services.d/rstudio/run

# copy custom start command and make it executable.
COPY config/start.sh /start.sh
RUN sudo chmod +x /start.sh

# reset MAKE
ENV MAKE 'make'

CMD [ "/start.sh" ]
