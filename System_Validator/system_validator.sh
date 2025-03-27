#!/bin/bash

RD='\e[31m' #Red
GR='\e[32m' #Green
RST='\e[0m'  #Reset

USB_COUNT=14
CUR_DIR=${PWD}
LOG_DIR=$CUR_DIR/log_dir
if [ -d $LOG_DIR ]; then
	rm -rf $LOG_DIR
	mkdir $LOG_DIR
else
	mkdir $LOG_DIR
fi

dmesg_log() {
	cd $LOG_DIR
	sudo dmesg -HT	       > dmesg_log
	sudo dmesg -HT -l err  > dmesg_err
	sudo dmesg -HT -l crit > dmesg_crit
	sudo dmesg -HT -l warn > dmesg_warn
}

curr_mods() {
	cd $LOG_DIR
	sudo lsmod > present_modules
}

machine_info() {
	cd $LOG_DIR
	PKG_INXI="inxi"
	if [ $(command -v $INXI) ]; then
		inxi -Fxxx > system_info
	else
		sudo apt install -y inxi > /dev/null
		inxi -Fxxx > system_info
	fi
}

sensor_info() {
	cd $LOG_DIR
	sudo sensors > sensor_info
}

usb_info() {	
	cd $LOG_DIR
	echo -e "***** USB info of the board *****" > usb_info
	printf "\n\n----- USB List count -----\n" >> usb_info
	WC=$(sudo lsusb | wc -l)
	echo "$WC" >> usb_info
	
	if [ $WC -eq $USB_COUNT ]; then
		echo -e "${GR} ***** USB Count Tested & OK *****${RST}"
	else
		echo -e "\n${RD} ***** USB Count MISMATCHED -- Please verify Again ***** ${RST}\n"
	fi
	
	printf "\n\n----- USB List ----- \n" >> usb_info
	sudo lsusb >> usb_info
	printf "\n\n" >> usb_info
	echo -e "----- Tree view of USB devices -----\n\n" >> usb_info
	sudo lsusb -t >> usb_info
	echo -e "----- Check for ttyACM -----\n" >> usb_info
	ls /dev/{ttyACM0,ttyACM1,ttyACM2} > /dev/null 2>&1
	TTY_CHK=$?
	if [ $TTY_CHK -eq 0 ]; then
		echo -e "\n${GR} *** INFO : ttyACM0,ttyACM1,ttyACM2 -- Tested & OK${RST}\n" | tee >(awk '{ gsub(/\x1b\[[0-9;]*m/, ""); print }' >> usb_info)
	else
		echo -e "\n${RD} *** ALERT : ttyACM0,ttyACM1,ttyACM2 -- N/A ***${RST}\n" | tee >(awk '{ gsub(/\x1b\[[0-9;]*m/, ""); print }' >> usb_info)
	fi
}

system_analysis() {
	cd $LOG_DIR

	systemd-analyze > /dev/null 2>&1
	SYSD=$?
	if [ $SYSD -eq 0 ]; then
		echo -e "${GR}*** System is Up & Running ***${RST}"
		systemd-analyze > system_analysis
	else
		echo -e "${RD}*** System NOT BOOTED yet ***${RST}"
		echo -e " ----- Listing Services in Wait queue -----"
		sudo systemctl list-jobs
		echo 
		echo -e "\n${RD}***** EXITING - STOP waiting/running services or Wait until Starup *****${RST}\n"
		exit 1
	fi

}

ls_services() {
	sudo systemctl list-units --type=service > services_info
}

pkg_info() {
	dpkg -l > pkgs_info
}

jetson_info() {
	#apt list --installed | grep jtop
	if [ $(command -v jtop) ]; then
		echo -e "jtop :${GR}Installed${RST}"
		JTOP_CHK=$(sudo systemctl is-active jtop.service)
		if [ "$JTOP_CHK" == "active" ]; then
			jetson_release | awk '{ gsub(/\x1b\[[0-9;]*m/, ""); print }' > jetson_info
		else
			echo -e "\n${RD} -> jtop : Service Inactive - Can't get jetson stats${RST}\n"
		fi
	else
		
		echo -e "\n${RD}-> jtop : NOT INSTALLED - Can't get jetson stats${RST}\n"
	fi
}

full_log(){
	FULL_LOG="full_sys_info_$(date +'%d-%m-%Y__%H-%M-%S').txt"
	
	cat << EOF > $FULL_LOG 
+------------------------------------------------------------------------------+
|			COMPLETE SYSTEM INFORMATION RECORD		       |
+------------------------------------------------------------------------------+

EOF
	echo -e "HOSTNAME : $HOSTNAME" 		>> $FULL_LOG
	echo -e "USERNAME : $USER" 		>> $FULL_LOG
	echo -e "SYSTEM   : $(uname -s)" 	>> $FULL_LOG
	echo -e "ARCH     : $(uname -m)"	>> $FULL_LOG
	echo -e "KERNEL   : $(uname -r)" 	>> $FULL_LOG
	echo -e "DISTRO   : $(lsb_release -d | awk '{print $2 " " $3 " " $4}')"  >> $FULL_LOG
	echo -e "RELEASE  : $(lsb_release -r | awk '{print $2}')"  >> $FULL_LOG
	echo -e "CODENAME : $(lsb_release -c | awk '{print $2}')"  >> $FULL_LOG

	printf "\n" >> $FULL_LOG
}

bt_chk() {
	BT_CHK=$(sudo systemctl is-active bluetooth.service)
	if [ "$BT_CHK" = "active" ]; then
		echo -e "Bluetooth : ${GR}active${RST}" 
	else
		echo -e "Bluetooth : ${RD}inactive${RST}"
	fi
}

wlan_chk() {
	WL_CHK=$(nmcli radio wifi)
	if [ "$WL_CHK" = "enabled" ]; then
		INF=$(iw dev | awk '$1=="Interface"{print $2}')
		echo -e "WIFI	  : ${GR}active${RST}"
	else
		echo -e "WIFI 	  : ${RD}inactive${RST}"
	fi
}

#Place the necessary modules that are to be check after bootup.
mod_chk() {
	#v4l2loopback wireguard
	echo 
	echo -e "----- Important Modules Check -----\n"
	echo -e "Module\t\t  Status"
	V4L2LB_MOD=$(sudo lsmod | grep v4l2loopback)
	if [ $? -eq 1 ]; then
		echo -e "v4l2loopback	- ${RD}N/A${RST}"
	else
		echo -e "v4l2loopback	- ${GR}Present${RST}"
	fi

	WG_MOD=$(sudo lsmod | grep wireguard)
	if [ $? -eq 1 ]; then
		echo -e "Wireguard	- ${RD}N/A${RST}"
	else
		echo -e "Wireguard	- ${GR}Present${RST}"
	fi
}

main() {
	system_analysis
	dmesg_log
	curr_mods
	machine_info
	sensor_info
	usb_info
	ls_services
	pkg_info
	full_log
	jetson_info
	
	echo -e "\n\n***** Logging DONE *****\n"
	echo -e "\n***** FURTHER H/W CHEKS ****\n"
	bt_chk
	wlan_chk
	mod_chk

}

main
