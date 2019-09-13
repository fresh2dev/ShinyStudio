ARG tag=latest
FROM dm3ll3n/shinystudio:$tag

### Additional customizations (apps, drivers, etc) to copy into the image.

COPY config/image/odbc/odbcinst.ini /etc/odbcinst.ini
COPY config/image/odbc/odbc.ini /etc/odbc.ini

COPY config/image/krb/krb5.conf /etc/krb5.conf

COPY config/image/vscode/User/settings.json /code-server-template/User/settings.json
COPY config/image/vscode/User/snippets /code-server-template/User/snippets

###
