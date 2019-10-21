ARG TAG=latest
FROM dm3ll3n/shinystudio:$TAG
ENV TAG=$TAG

### Additional customizations (apps, drivers, etc) to copy into the image.

COPY config/image/odbc/odbcinst.ini /etc/odbcinst.ini
COPY config/image/odbc/odbc.ini /etc/odbc.ini

COPY config/image/krb/krb5.conf /etc/krb5.conf

###
