# Bluetooth Sound Alert System

## Problem Description

This application solves the problem of detecting when a specific Bluetooth device (Sony PlayStation 4 Controller) connects to the system and plays an audio alert to notify the user. The system continuously monitors Bluetooth connections and plays a sound notification only when the target device newly connects (reconnects), not when it's already connected.

## How It Works

The system consists of two main components:

1. **manualalert.sh** - A bash script that continuously monitors Bluetooth connections
2. **manualalert.service** - A systemd service that runs the monitoring script

### Key Features

- **Targeted Device Detection**: Monitors for devices with MAC address pattern "60:5B:B4:" (Sony PlayStation 4 Controller)
- **Reconnection Detection**: Only plays sound on new connections, not for devices already connected
- **Continuous Monitoring**: Runs as a systemd service with automatic restart on failure
- **Audio Notification**: Plays `/opt/ati/manual.wav` when target device connects
- **Logging**: All output is logged to `/opt/ati/ps4_manualalert.log`

## Installation

### Prerequisites

- Ubuntu system with systemd
- `bluetoothctl` command available
- `aplay` command for audio playback
- Root/sudo access for installation
- **Sound Card Configuration**: The script requires the correct ALSA sound card and device configuration. The script is currently configured to use `hw:1,4` (line 74 in `manualalert.sh`). You must update this to match your system's audio hardware before use.

  To find your sound card and device numbers, run:
  ```bash
  aplay -l
  ```
  
  Look for the card number and device number in the output, then update line 74 in the script:
  ```bash
  aplay -D hw:CARD,DEVICE "/opt/ati/manual.wav" 2>/dev/null
  ```
  
  Replace `CARD` with your card number and `DEVICE` with your device number.

### Installation Steps

1. **Copy the script to system location:**
   ```bash
   sudo cp manualalert.sh /etc/systemd/manualalert.sh
   sudo chmod +x /etc/systemd/manualalert.sh
   ```

2. **Copy the audio file:**
   ```bash
   sudo cp manual.wav /opt/ati/manual.wav
   ```

3. **Install the systemd service:**
   ```bash
   sudo cp manualalert.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

4. **Enable and start the service:**
   ```bash
   sudo systemctl enable manualalert.service
   sudo systemctl start manualalert.service
   ```

## Configuration

### Audio File

The system plays `/opt/ati/manual.wav` when a device connects. Ensure this file exists and is accessible.

## Usage

Once installed and started, the service runs automatically in the background. It will:

1. Monitor Bluetooth connections every 2 seconds
2. Detect when a device matching the MAC pattern connects
3. Play the audio alert only on new connections
4. Log all activity to `/opt/ati/ps4_manualalert.log`

## Debugging

### Check Service Status

```bash
sudo systemctl status manualalert.service
```

### View Service Logs

```bash
sudo tail -f /opt/ati/ps4_manualalert.log
```

### Manual Testing

Run the script manually to test functionality:

```bash
sudo /etc/systemd/manualalert.sh
```

### Common Issues

1. **Audio not playing**: 
   - Verify `/opt/ati/manual.wav` exists
   - Check if `aplay` command works: `aplay /opt/ati/manual.wav`

2. **Device not detected**:
   - Verify MAC address pattern matches your device
   - Check if `bluetoothctl devices` shows your device
   - Ensure device is actually connecting (not just paired)

3. **Service not starting**:
   - Check service status: `sudo systemctl status manualalert.service`
   - Verify script permissions: `ls -la /etc/systemd/manualalert.sh`
   - Check systemd logs: `sudo journalctl -u manualalert.service`

4. **Log file issues**:
   - Ensure `/opt/ati/` directory exists
   - Check log file permissions: `ls -la /opt/ati/ps4_manualalert.log`

### Service Management

- **Start service**: `sudo systemctl start manualalert.service`
- **Stop service**: `sudo systemctl stop manualalert.service`
- **Restart service**: `sudo systemctl restart manualalert.service`
- **Disable service**: `sudo systemctl disable manualalert.service`

## File Locations

- **Script**: `/etc/systemd/manualalert.sh`
- **Service file**: `/etc/systemd/system/manualalert.service`
- **Audio file**: `/opt/ati/manual.wav`
- **Log file**: `/opt/ati/ps4_manualalert.log`

## Technical Details

- **Monitoring interval**: 2 seconds
- **Service restart**: Automatic restart on failure with 5-second delay
- **User context**: Runs as root user
- **Dependencies**: Requires bluetooth.service to be running
- **Detection method**: Uses `bluetoothctl` to query connected devices 