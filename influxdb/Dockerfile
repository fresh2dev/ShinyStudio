FROM influxdb:latest

COPY ./config/influxdb.conf /etc/influxdb/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]
