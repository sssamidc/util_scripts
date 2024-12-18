#!/usr/bin/bash

# Step 1: Print timestamp
# Get current timestamp in "DD-MM-YYYY HH:MM:SS" format
timestamp=$(/usr/bin/date +"%d-%m-%Y %H:%M:%S")

# Print the formatted output
echo "################################################################################"
echo "##"
echo "## Current Time: $timestamp"
echo "##"
echo "################################################################################"
echo
echo

# Step 2: Change directory
echo "FM 4.2.1.3: Changing directory to /home/ubuntu/for_sss/FM_installation/fm_4.2.1.3/static"
cd /home/ubuntu/for_sss/FM_installation/fm_4.2.1.3/static || { echo "FM 4.2.1.3: Failed to change directory"; exit 1; }
echo `pwd`

## Step 3: Bring the containers down
echo "FM 4.2.1.3: Stopping containers..."
/usr/local/bin/docker-compose -p fm -f docker_compose_vFM_v4.2.1.3.yml down 

if [ $? -eq 0 ]; then
	echo "FM 4.2.1.3: Containers stopped successfully."
else
	echo "FM 4.2.1.3: Failed to stop containers."
	exit 1
fi
echo
echo

# Step 4: Sleep for a few seconds
echo "FM 4.2.1.3: Sleeping for 5 seconds..."
/usr/bin/sleep 5
echo
echo

# Step 5: Bring the containers back up
echo "FM 4.2.1.3: Starting containers..."
/usr/local/bin/docker-compose -p fm -f docker_compose_vFM_v4.2.1.3.yml up -d
if [ $? -eq 0 ]; then
	echo "FM 4.2.1.3: Containers started successfully."
else
	echo "Failed to start containers."
	exit 1
fi
echo
echo

# Step 6: Print the status of each container
echo "Printing status of the containers..."
docker ps
echo
echo

# Step 7: Exit
echo "Exiting script."
exit 0
