#!/usr/bin/env bash

site_port="$1"
content_path="$2"

./controls/stop.sh "$site_port"

./controls/start.sh "$site_port" "$content_path"
