#!/usr/bin/bash

while true
do
	echo '---------------------------------------------------------------------------------'
	echo "`(sar -d 0 | tail -n+4)`"
	sleep 60
done
