FROM dm3ll3n/shinystudio

### Additional customizations (apps, drivers, etc)

COPY configs/odbc/odbcinst.ini /etc/odbcinst.ini
COPY configs/odbc/odbc.ini /etc/odbc.ini

COPY configs/krb/krb5.conf /etc/krb5.conf

COPY configs/vscode/User/settings.json /code-server-template/User/settings.json
COPY configs/vscode/User/snippets /code-server-template/User/snippets

###
