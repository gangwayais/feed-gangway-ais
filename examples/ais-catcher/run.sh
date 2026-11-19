#!/bin/sh
# AIS-catcher with Gangway AIS as one more UDP output.
# Replace the placeholders with the host and port the feed page gives your station:
# https://gangwayais.com/stations/feed-us/
# Keep the outputs you already have. Each -u adds one destination.

AIS-catcher -d:0 \
  -u "<your-host>" "<your-port>"
