#!/usr/bin/bash

while true
do
	echo '---------------------------------------------------------------------------------'
	echo "`(sar -u ALL 0 | tail -n1)`"
	sleep 60
done
