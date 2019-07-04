FROM dm3ll3n/shinystudio

### Additional customizations (apps, drivers, etc) to copy into the image.

COPY configs/global/odbc/odbcinst.ini /etc/odbcinst.ini
COPY configs/global/odbc/odbc.ini /etc/odbc.ini

COPY configs/global/krb/krb5.conf /etc/krb5.conf

COPY configs/global/vscode/User/settings.json /code-server-template/User/settings.json
COPY configs/global/vscode/User/snippets /code-server-template/User/snippets

###
