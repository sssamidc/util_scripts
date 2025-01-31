# BOOT TIME MONITOR (BTM)

This script collect all the data of systemd analyze and stores it into a 
`system_analyze.csv` file. When ever your system reboots or starts this script
will collect the `systemd-analyze`. It'll wait until your system has reached 
complete userspace if the userspace is not usable then the script won't run.

NOTE : This script will reboot the system after every 1 min until the 
`MAX_BOOT_NUM=110` is reached in the file. You can change this number as per
your needs

## Follow Steps

1. Place `boot_mon_aarch64` in `$HOME` dir.
2. Edit `crontab -e` and append to end save and exit.
 - `* * * * * /home/$USER/boot_mon_aarch64`

For `x86_64` systems use `boot_mon_x86_64` script and follow above steps
