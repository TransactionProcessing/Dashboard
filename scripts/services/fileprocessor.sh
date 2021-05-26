#!/bin/sh
ACTION="$1"
sudo systemctl $ACTION kestrel-fileprocessor.service
