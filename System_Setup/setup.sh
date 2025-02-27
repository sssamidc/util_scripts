#!/bin/bash

RD='\e[31m' #RED
GR='\e[32m' #GREEN
CO='\e[0m'  #COLOR OFF

#Pass argument as --dyanalog
dynalog() {
	sudo apt update -y && sudo apt autoremove -y
	sudo rm -rf /var/chache/snapd
	sudo apt autoremove --purge snapd -y
	sudo apt install -y alsa-utils \
	       		    apt-transport-https \
			    avahi-daemon \
			    bluez bridge-utils \
			    ca-certificates chrony \
			    curl gnupg-agent haveged \
			    isc-dhcp-server \
			    kmod \
			    modemmanager \
			    netplan.io \
			    net-tools \
			    network-manager \
			    openssh-server \
			    rsyslog \
			    software-properties-common \
			    systemd \
			    udev \
			    qemu-user-static \
			    language-pack-en \
			    htop mosh rsync \
			    tmux vim \
			    wireless-tools \
			    traceroute \
			    inetutils-ping \
			    nmap tzdata ufw

	sudo apt install -y cuda-minimal-build-11-4 \
			 cuda-command-line-tools-11-4 \
			 cuda-libraries-11-4 \
			 libcudnn8 \
			 libnvinfer8 libnvinfer-plugin8

	wget https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_arm64.tar.gz -O - | tar xz && sudo mv yq_linux_arm64 /usr/bin/yq
	rm install-man-page.sh yq.1

	#FIREWALL
	sudo ufw allow from 192.168.1.0/24 to any port 60000:61000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 10000:60000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 10000:60000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7501 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7502 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7503 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 3478
	sudo ufw allow from 192.168.1.0/24 to any port 3479
	sudo ufw status

	#DOCKER
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-buildx docker-ee docker-ce; do sudo apt-get remove -y $pkg; done

	sudo install -y -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	sudo echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt update -y
	sudo apt-get install -y docker-ce \
	       		     docker-ce-cli \
			     containerd.io \
			     docker-buildx-plugin \
			     docker-compose-plugin \
			     nvidia-docker2

	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker

	echo -e "\n\n${GR}------------- TESTING DOCKER ------------${CO}\n\n"
	
	sudo docker run hello-world

	sudo nvidia-ctk runtime configure --runtime=docker
	sudo systemctl restart docker

	sudo mkdir -p /opt/ati/{run,data,models,ref-data/map,uniflash,config,out}
        sudo chown -R ati:ati /opt/ati

	echo -e "\n${GR}-------------- SYSTEM SETUP COMPLETE --------------${CO}\n"
}

#Pass argument as --advantech for advantech boards
advantech() {

	sudo apt update -y && sudo apt autoremove -y
	sudo rm -rf /var/chache/snapd
	sudo apt purge snapd -y
	sudo apt install -y alsa-utils \
	       		    apt-transport-https \
			    avahi-daemon \
			    bluez bridge-utils \
			    ca-certificates chrony \
			    curl gnupg-agent haveged \
			    isc-dhcp-server \
			    kmod \
			    modemmanager \
			    netplan.io \
			    net-tools \
			    network-manager \
			    openssh-server \
			    rsyslog \
			    software-properties-common \
			    systemd \
			    udev \
			    qemu-user-static \
			    language-pack-en \
			    htop mosh rsync \
			    tmux vim \
			    wireless-tools \
			    traceroute \
			    inetutils-ping \
			    nmap tzdata ufw
	
	sudo apt install cuda-minimal-build-11-4 \
			 cuda-command-line-tools-11-4 \
			 cuda-libraries-11-4 \
			 libcudnn8 \
			 libnvinfer8 libnvinfer-plugin8

	wget https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_arm64.tar.gz -O - | tar xz && sudo mv yq_linux_arm64 /usr/bin/yq
	rm install-man-page.sh yq.1

	#FIREWALL
	sudo ufw allow from 192.168.1.0/24 to any port 60000:61000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 10000:60000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 10000:60000 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7501 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7502 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 7503 proto udp
	sudo ufw allow from 192.168.1.0/24 to any port 3478
	sudo ufw allow from 192.168.1.0/24 to any port 3479
	sudo ufw status

	#DOCKER
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-buildx docker-ee docker-ce; do sudo apt-get remove $pkg; done

	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	sudo echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt update -y
	sudo apt-get install -y docker-ce \
	       		     docker-ce-cli \
			     containerd.io \
			     docker-buildx-plugin \
			     docker-compose-plugin \
			     nvidia-docker2
	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker

	echo -e "\n\n${GR}------------- TESTING DOCKER ------------${CO}\n\n"
	
	docker run hello-world

	sudo nvidia-ctk runtime configure --runtime=docker
	sudo systemctl restart docker

	sudo mkdir -p /opt/ati/{run,data,models,ref-data/map,uniflash,config,out}
        sudo chown -R ati:ati /opt/ati

	echo -e "\n${GR}-------------- SYSTEM SETUP COMPLETE --------------${CO}\n"
}

usage() {
	echo -e "
Usage	    : $0 [-adv] | [-dyn]
Options     : [-adv] -- For Advantech Boards
	      [-dyn] -- For Dynalog Boards

Description : To use this script  you'll need atleas one argument to be passed
	      in while running the script.
"

}

ARG_CNT=$#
main() {
	if [ $ARG_CNT -eq 0 ];then
		usage
	elif [ "$1" == "-adv" ]; then
		advantech
	elif [ "$1" == "-dyn" ]; then
		dynalog
	fi
}

main $@
