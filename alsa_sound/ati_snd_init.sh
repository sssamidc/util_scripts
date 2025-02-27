#!/bin/bash

amixer -c APE cset name="I2S5 Mux" ADMAIF5
amixer -c APE cset name="H40-SGTL Lineout Playback Switch" "on"
amixer -c APE cset name="H40-SGTL Lineout Playback Volume" 40
alsactl restore
