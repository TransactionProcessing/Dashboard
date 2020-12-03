#!/bin/sh
ACTION="$1"
sudo systemctl $ACTION kestrel-vouchermanagement.service
