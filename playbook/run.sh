#!/bin/bash

idr_home="/home/idr/idr_client/"

cd $idr_home && ./client -c config.yaml >> extracts.log

exit 0

