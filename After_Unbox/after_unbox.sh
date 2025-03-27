#!/bin/bash

RD='\e[31m'   # Red color
GR='\e[32m'   # Green color
CY='\e[36m'   # Cyan
DEF='\e[0m'   # Reset to default color

#Collect System Information
sys_info() {
	echo -e "\n----- System Info -----\n"
	echo -e "CPU	 : ${GR}$(jetson_release | grep -oP 'Model:\s*\K.*' | awk '{print $1 " " $2}')${DEF}"
        echo -e "USERNAME : ${GR}$USER${DEF}"
	echo -e "HOSTNAME : ${GR}$HOSTNAME${DEF}"
        echo -e "SYSTEM   : ${GR}$(uname -s)${DEF}"
        echo -e "ARCH     : ${GR}$(uname -m)${DEF}"
        echo -e "KERNEL   : ${GR}$(uname -r)${DEF}"
        echo -e "DISTRO   : ${GR}$(lsb_release -d | grep -oP ':\s*\K.*')${DEF}"
        echo -e "RELEASE  : ${GR}$(lsb_release -r | grep -oP ':\s*\K.*')${DEF}"
        echo -e "CODENAME : ${GR}$(lsb_release -c | grep -oP ':\s*\K.*')${DEF}"
	echo -e "JETPACK  : ${GR}$(jetson_release | grep -oP 'Jetpack\s*\K.*' | awk '{print $1}')${DEF}"
	nvidia-smi > /dev/null
	if [ $? -eq 0 ]; then
		echo -e "CUDA 	 : ${GR}$(nvidia-smi | grep -oP 'CUDA\s*\K.*' | awk '{print $2}')${DEF}"
	else
		echo -e "CUDA	 : ${RD}N/A${DEF}"
	fi

	if [ "$USER" != "ati" ]; then
		echo -e "\n${RD} Please change USER to \"ati\"${DEF}\n"
	fi
}

#Check if jtop is installed and active
jtop_chk() {
	echo -e "\n----- Services & Devices Info -----\n"
	JTOP_CHK=$(sudo systemctl is-active jtop.service)
	if [ "$JTOP_CHK" = "active" ]; then
		echo -e "jtop	  : ${GR}active${DEF}" 
	else
		echo -e "jtop 	  : ${RD}inactive${DEF}"
	fi
}

#Bluetooth check 
bt_chk() {
	BT_CHK=$(sudo systemctl is-active bluetooth.service)
	if [ "$BT_CHK" = "active" ]; then
		echo -e "Bluetooth : ${GR}active${DEF}" 
	else
		echo -e "Bluetooth : ${RD}inactive${DEF}"
	fi
}

#This is used for wifi check
wlan_chk() {
	WL_CHK=$(nmcli radio wifi)
	if [ "$WL_CHK" = "enabled" ]; then
		INF=$(iw dev | awk '$1=="Interface"{print $2}')
		echo -e "WIFI	  : ${GR}active${DEF}" 
		echo
		echo -e "----- WIFI info -----"
		echo 
		echo -e "Interface :${CY} $INF${DEF}"
		echo -e "WIFI Card :${CY} $(lspci | grep Network | grep -oP 'controller:\s*\K.*')${DEF}"
		echo -e "Local IP  :${CY} $(ip addr show $INF | awk '/inet / {print $2}' | cut -d/ -f1)${DEF}"
		echo -e "Conn	  :${CY} $(iw dev | grep 'ssid' | awk '{print $2}')${DEF}"
	else
		echo -e "WIFI 	  : ${RD}inactive${DEF}"
	fi
}

#Check for required modules. If you want more modules to be checked then just append 
# it to `mods` variable in the function below.
mod_chk() {
	#v4l2loopback wireguard
	echo 
	echo -e "----- Important Modules Check -----\n"
	echo -e "Module\t\t  Status"
	mods=("v4l2loopback" "wireguard" "typec")
	for i in ${mods[@]}; do
		if sudo lsmod | grep $i > /dev/null; then 
			echo -e "$i	- ${GR}Present${DEF}"
		else
			echo -e "$i \t- ${RD}N/A${DEF}"
		fi
	done
}

#CPU info of jetson
cpu_info() {
	echo
	echo -e "----- CPU Info -----\n"
	jetson_release | grep Jetpack
	lscpu | grep CPU | head -n 2
}

#GPU info. If there's no output form the `nvidia-smi` then CUDA packages are not installed 
# Install required CUDA dependencies and required drivers.
gpu_info() {
	
	echo -e "\n----- GPU Info -----\n"
	nvidia-smi > /dev/null
	if [ $? -eq 0 ]; then
		nvidia-smi
	else
		echo -e "\n${RD}** Please Install CUDA to access GPU details **${DEF}\n"
	fi
}

#Memory usage
mem_info() {
	echo -e "\n----- Memory -----\n"
	free -h
}

#Disk Usage
dsk_info() {
	echo -e "----- Disk Info -----\n"
	df -H | head -n 2
	
}

#This just give the count of all the USB's. Try to allocate all the ports avalilable with some device
# eg. pendrive, keyboard, mouse,etc.
usb_chk() {
	echo -e "\n----- USB list -----\n"
	echo -e "NOTE : Connect all the ports with some h/w and test again"
	lsusb -t | wc -l 
}

#ALL the functions above will be called in main
main() {
	sys_info
	jtop_chk
	bt_chk
	wlan_chk
	mod_chk
	cpu_info
	gpu_info
	mem_info
	dsk_info
	usb_chk

	echo -e "\n***** EOF *****\n"
}

main
