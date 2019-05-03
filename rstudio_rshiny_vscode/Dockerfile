FROM rocker/verse:latest

# essential vars
ENV DISABLE_AUTH true
ENV R_LIBS_USER /r-libs
ENV APPLICATION_LOGS_TO_STDOUT false
# reduce time spent waiting for libs to compile.
# http://www.rexamine.com/2015/07/speeding-up-r-package-installation-process/
# ENV MAKE 'make -j 8'

# add shiny immediately and expose port 3838.
RUN export ADD=shiny && bash /etc/cont-init.d/add
EXPOSE 3838

RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y curl nano

# create shared /r-libs directory and ensure it's writeable by all.
RUN mkdir /r-libs && \
    echo ".libPaths( c( '/r-libs', .libPaths() ) )" >> /usr/local/lib/R/etc/Rprofile.site

# install R packages
# rmarkdown 1.12 does not display floating TOC; downgrade to 1.11.
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rmarkdown/rmarkdown_1.11.tar.gz', repos=NULL)" && \
    R -e "install.packages(c('reticulate', 'png', 'DBI', 'odbc', 'shinydashboard', 'flexdashboard', 'shinycssloaders', 'DT', 'visNetwork', 'networkD3'))" && \
    git clone https://github.com/dm3ll3n/Shiny-GEM.git '/srv/shiny-server/Shiny-GEM' && \
    Rscript '/srv/shiny-server/Shiny-GEM/install-requirements.R' && \
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
    pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip && \
    pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org wheel && \
    pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org \
        wheel Cython numpy matplotlib pandas tqdm ezpq paramiko requests \
        pylint jupyter

# install pwsh
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux
RUN apt-get install -y gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list && \
    apt-get update && \
    apt-get install -y powershell

# install VS code-server
RUN wget https://github.com/codercom/code-server/releases/download/1.939-vsc1.33.1/code-server1.939-vsc1.33.1-linux-x64.tar.gz -O /tmp/vs-code-server.tar.gz && \
    mkdir /tmp/vs-code-server && \
    tar -xzf /tmp/vs-code-server.tar.gz --strip 1 --directory /tmp/vs-code-server && \
    cp -f /tmp/vs-code-server/code-server /usr/local/bin/code-server && \
    rm -rf /tmp/vs-code-server.tar.gz /tmp/vs-code-server && \
    mkdir /code-server-template && \
    code-server --user-data-dir /code-server-template --install-extension ms-python.python && \
    code-server --user-data-dir /code-server-template --install-extension ms-vscode.powershell && \
#     code-server --user-data-dir /code-server-template --install-extension ms-mssql.mssql && \
    code-server --user-data-dir /code-server-template --install-extension yzhang.markdown-all-in-one && \
    echo '#!/usr/bin/env bash' > '/setup_vscode.sh' && \
    echo 'cp -Rn /code-server-template/* ~/.local/share/code-server' >> '/setup_vscode.sh' && \
    chmod 555 '/setup_vscode.sh' && \
    # unsure why this is necessary, but it solves a fatal 'file not found' error.
    mkdir -p /home/travis/build/codercom/code-server/packages/server/build/web && \
    echo '' > /home/travis/build/codercom/code-server/packages/server/build/web/index.html

COPY config/vscode/User/settings.json /code-server-template/User/settings.json
COPY config/vscode/User/snippets /code-server-template/User/snippets

# install SQL Server odbc driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools

# install PostgreSQL odbc driver
RUN apt-get install -y odbc-postgresql

# install cloudera odbc driver
RUN wget https://downloads.cloudera.com/connectors/ClouderaImpala_ODBC_2.6.2.1002/Debian/clouderaimpalaodbc_2.6.2.1002-2_amd64.deb -O /tmp/clouderaimpalaodbc_amd64.deb && \
    dpkg -i /tmp/clouderaimpalaodbc_amd64.deb && \
    rm -f /tmp/clouderaimpalaodbc_amd64.deb

# copy odbc driver and dns configs.
COPY config/odbc/odbcinst.ini /etc/odbcinst.ini
COPY config/odbc/odbc.ini /etc/odbc.ini

# copy custom run commands.
COPY config/rstudio/run /etc/services.d/rstudio/run
COPY config/vscode/run /etc/services.d/vscode/run

# custom configs
COPY config/rstudio/rserver.conf /etc/rstudio/rserver_custom.conf
COPY config/shiny/shiny-server.conf /etc/shiny-server/shiny-server.conf

# copy custom start command and make it executable.
COPY config/start.sh /start.sh
RUN chmod +x /start.sh

# reset MAKE
# ENV MAKE 'make'

CMD [ "/start.sh" ]
