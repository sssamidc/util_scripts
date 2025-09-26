#!/usr/bin/env bash

## MAC Address pattern
mac_pattern="60:5B:B4:"           ## For Sony Playstation 4 Controller
## mac_pattern="8C:FD:15:"

## Boolean flag to track device connection state (false = not connected, true = connected)
ps4_connected=false

## Function to create service log file if it doesn't exist
create_service_log_file() {
    if ! [ -f /opt/ati/ps4_manualalert.log ]; then
        echo "Creating service log file at /opt/ati/ps4_manualalert.log"
        touch /opt/ati/ps4_manualalert.log
    else
        echo "Service log file already exists at /opt/ati/ps4_manualalert.log"
    fi
}

## Function to set ownership of the log file
change_service_log_ownership() {
    # if ! chown subhrasarkar:subhrasarkar /opt/ati/ps4_manualalert.log; then
    if ! chown ati:ati /opt/ati/ps4_manualalert.log; then
        echo "ERROR: Failed to change ownership of service log file to ati:ati"
    else
        echo "Successfully changed ownership of service file to ati:ati"
    fi
}

## Function to check if matching device is connected
ps4_controller_connected() {
    # Get first matching device (since only one exists)
    local matching_device=$(for dev in $(bluetoothctl devices | awk '{print $2}'); do bluetoothctl info $dev | grep -q "Connected: yes" && echo $dev; done)

    if [ -n "$matching_device" ]; then
        echo "$matching_device"
        return 0
    else
        return 1
    fi
}

## Driver function to run the script
main() {
    # Print horizontal line
    echo "--------------------------------------------------------------------------------"

    # Log start time
    start_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo "Script started at: $start_time"

    # Create service log file
    create_service_log_file
    echo "Service log file created"

    # Change ownership of the log file
    change_service_log_ownership
    echo "Service log file ownership changed"

    # Main monitoring loop
    while true; do
        # Check if matching device is currently connected
        if current_device=$(ps4_controller_connected); then
            # Device is connected - check previous state
            if [ "$ps4_connected" = false ]; then
                # Device was not connected before, now it is - NEW CONNECTION!
                echo "Found newly connected matching device: ${current_device}"

                # Play the WAV file using aplay
                aplay "/opt/ati/manual.wav" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "Audio played successfully for device ${current_device}"
                else
                    echo "Failed to play audio for device ${current_device}"
                fi

                # Update state to connected
                ps4_connected=true
            fi
            # If ps4_connected was true, device was already connected - no action needed

        else
            # No matching device connected - update state to disconnected
            ps4_connected=false
        fi

        # Wait before next check
        sleep 2
    done

    # Print horizontal line
    echo "--------------------------------------------------------------------------------"
}

## Starting point of the script
main