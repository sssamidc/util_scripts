#!/usr/bin/bash

################################################################################
##                                                                            ##
## Brief:                                                                     ##
##                                                                            ##
## Simple bash script to create quarterly directories of the following format ##
## in path /home/subhrasarkar/Documents/work_notes/jira_numbers               ##
##                                                                            ##
##        <quarter-no>_YYYY                                                   ##
##                                                                            ##
## How to run it?                                                             ##
##                                                                            ##
## Running it as a cron job                                                   ##
##                                                                            ##
## Author: Subhra S Sarkar <subhra.sarkar@atimotors.com>                      ##
##                                                                            ##
## Date: 11-Sep-2024                                                          ##
##                                                                            ##
## Version: 1.0                                                               ##
##                                                                            ##
################################################################################

## Get the month & year
year=$(date +"%Y")
month=$(date +"%-m")

## Get the quarter number
if [ $month -ge 4 ] && [ $month -le 6 ]; then
	quarter="Q1"
elif [ $month -ge 7 ] && [ $month -le 9 ]; then
	quarter="Q2"
elif [ $month -ge 10 ] && [ $month -le 12 ]; then
	quarter="Q3"
else
	quarter="Q4"
	year=$(date -d "last year" +"%Y")
fi

## Directory creation
directory="${quarter}_${year}"

## Move to appropriate path & create directory
if [ ! -d "$directory" ]; then
	cd /home/subhrasarkar/Documents/work_notes/jira_numbers/
	mkdir "$directory"
	echo "Directory created successfully: $directory"
else
	echo "Directory already exists: $directory"
fi
