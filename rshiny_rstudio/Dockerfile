FROM rocker/verse:latest

ENV DISABLE_AUTH true
ENV USER rstudio

ENV R_LIBS_USER /r-libs
ENV APPLICATION_LOGS_TO_STDOUT false
# http://www.rexamine.com/2015/07/speeding-up-r-package-installation-process/
ENV MAKE 'make -j 8'

RUN export ADD=shiny && bash /etc/cont-init.d/add

EXPOSE 3838

RUN sudo mkdir -p /r-libs && \
	R -e "remove.packages('rmarkdown')" && \
	R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rmarkdown/rmarkdown_1.11.tar.gz', repos=NULL)" && \
	echo ".libPaths( c( '/r-libs', .libPaths() ) )" >> /usr/local/lib/R/etc/Rprofile.site

COPY config/rserver.conf /etc/rstudio/rserver_custom.conf
COPY config/run /etc/services.d/rstudio/run

COPY config/start.sh /start.sh
RUN sudo chmod +x /start.sh

RUN git clone https://github.com/rstudio/shiny-examples /home/${USER}/shiny-examples

CMD [ "/start.sh" ]
