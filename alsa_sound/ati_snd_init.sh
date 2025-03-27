#!/bin/bash

wait_set() {
    # Wait until the system is fully running
    systemd-analyze > /dev/null
    while [ $? -ne 0 ]; do
        sleep 60
        systemd-analyze > /dev/null
    done

	amixer -c APE cset name="I2S5 Mux" ADMAIF5
	amixer -c APE cset name="H40-SGTL Lineout Playback Switch" "on"
	amixer -c APE cset name="H40-SGTL Lineout Playback Volume" 40
	alsactl restore

	/bin/aplay /home/ati/beep.wav
}

wait_set
