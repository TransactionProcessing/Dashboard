#!/bin/sh
ACTION="$1"
sudo systemctl $ACTION kestrel-supporttools-healthchecks.service
