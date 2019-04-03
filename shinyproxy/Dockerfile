FROM openjdk:8-jre

RUN mkdir -p /opt/shinyproxy

RUN wget https://www.shinyproxy.io/downloads/shinyproxy-2.2.1.jar -O /opt/shinyproxy/shinyproxy.jar
# RUN wget https://www.shinyproxy.io/downloads/shinyproxy-2.1.0.jar -O /opt/shinyproxy/shinyproxy.jar

COPY config/templates /opt/shinyproxy/templates
COPY config/sites /opt/shinyproxy/sites

COPY config/start_site.sh /opt/shinyproxy/start_site.sh
RUN chmod +x /opt/shinyproxy/start_site.sh

WORKDIR /opt/shinyproxy/
CMD ["/opt/shinyproxy/start_site.sh"]
# CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
