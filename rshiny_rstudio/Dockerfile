FROM rocker/verse:latest

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
	chmod 777 /r-libs && \
	echo ".libPaths( c( '/r-libs', .libPaths() ) )" >> /usr/local/lib/R/etc/Rprofile.site

# rmarkdown 1.12 does not display floating TOC; downgrade to 1.11.
# R -e "remove.packages('rmarkdown')" && \
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rmarkdown/rmarkdown_1.11.tar.gz', repos=NULL)"

# copy custom run commands.
COPY config/rserver.conf /etc/rstudio/rserver_custom.conf
COPY config/run /etc/services.d/rstudio/run

# copy custom start command and make it executable.
COPY config/start.sh /start.sh
RUN sudo chmod +x /start.sh

CMD [ "/start.sh" ]
