#!/usr/bin/env bash

ln -sf "/opt/shinyproxy/sites/${SITEID}.yml" /opt/shinyproxy/application.yml

java -jar /opt/shinyproxy/shinyproxy.jar
