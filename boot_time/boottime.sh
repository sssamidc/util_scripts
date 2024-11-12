#!/bin/bash

# Run systemd-analyze to get the boot times
output=$(systemd-analyze)

# Extract kernel boot time in seconds (could be in minutes or seconds)
kernel_time=$(echo "$output" | grep -oP '\d+\.\d+s \(kernel\)' | sed 's/[^0-9.]//g')

# Extract userspace boot time in seconds (could be in minutes or seconds)
userspace_time=$(echo "$output" | grep -oP '\d+(\.\d+)?(min)?s \(userspace\)' | sed 's/[^0-9.]//g')

# Convert userspace time from minutes to seconds if necessary
if [[ "$userspace_time" =~ "min" ]]; then
  userspace_time=$(echo "$userspace_time" | sed 's/min//g')
  userspace_time=$(echo "$userspace_time * 60" | bc)
fi

# Get current time in 12-hour format (AM/PM) with just the hour
current_time=$(date +'%I:%M:%S %p')

# Output the formatted result
echo "$current_time,$kernel_time,$userspace_time"

sleep 5

# Reboot the system
`/usr/sbin/reboot`
