#!/bin/bash

# Define the output CSV file
LOG_FILE="boot_times.csv"

# Run systemd-analyze time to get the bootup times
bootup_info=$(systemd-analyze time)

# Function to convert time (e.g., "1min 9.309s" or "3.312s") to seconds
convert_to_seconds() {
    local time_str=$1
    local total_seconds=0

    # If the time includes "min", convert minutes to seconds
    if [[ $time_str =~ ([0-9]+)min ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]} * 60))
    fi
    
    # If the time includes "s", add the seconds part
    if [[ $time_str =~ ([0-9.]+)s ]]; then
        total_seconds=$(echo "$total_seconds + ${BASH_REMATCH[1]}" | bc)
    fi

    # Return the total time in seconds
    echo "$total_seconds"
}

# Extract kernel and userspace times from the systemd-analyze output
kernel_time=$(echo "$bootup_info" | grep -oP '\d+\.\d+s \(kernel\)' | sed 's/ \(kernel\)//')
userspace_time=$(echo "$bootup_info" | grep -oP '\d+min \d+\.\d+s \(userspace\)' || echo "")

# If userspace time is not found, handle fallback to just seconds
if [[ -z "$userspace_time" ]]; then
    userspace_time=$(echo "$bootup_info" | grep -oP '\d+\.\d+s \(userspace\)')
fi

# Convert both kernel and userspace times to seconds
kernel_time_seconds=$(convert_to_seconds "$kernel_time")
userspace_time_seconds=$(convert_to_seconds "$userspace_time")

# Capture the current timestamp in 12-hour AM/PM format
timestamp=$(date +"%I:%M %p")

# Log the result to the CSV file (header check, if not exist)
if [ ! -f "$LOG_FILE" ]; then
    echo "Timestamp,Kernel Boot Time (seconds),Userspace Boot Time (seconds)" > "$LOG_FILE"
fi

# Append the new log entry with the timestamp and times
echo "$timestamp,$kernel_time_seconds,$userspace_time_seconds" >> "$LOG_FILE"

# Output the logged entry (optional)
echo "Logged: $timestamp, Kernel Boot Time: $kernel_time_seconds seconds, Userspace Boot Time: $userspace_time_seconds seconds"

