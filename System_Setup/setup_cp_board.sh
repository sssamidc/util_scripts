#!/bin/bash

RD='\e[31m' #RED
GR='\e[32m' #GREEN
CO='\e[0m'  #COLOR OFF

# Log file for setup
LOG_FOLDER="$HOME/logs/cp_board_setup"
LOG_FILE="${LOG_FOLDER}/setup_cp_board.log"

# Create log folder if it doesn't exist
mkdir -p "$LOG_FOLDER" || { echo -e "${RD}Failed to create log folder.${CO}"; exit 1; }

# Function to log messages to console and file
log() {
    local message="$1"
    local color="$2"
    echo -e "${color}${message}${CO}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"
}

# Function to handle errors
handle_error() {
    local error_message="$1"
    log "ERROR: ${error_message}" "$RD"
    exit 1
}

# Common setup steps
common_setup() {
    log "Updating system packages..." "$GR"
    sudo apt update -y || handle_error "Failed to update system packages."
    sudo apt autoremove -y || handle_error "Failed to remove unnecessary packages."

    log "Removing Snap and its cache..." "$GR"
    sudo rm -rf /var/cache/snapd || handle_error "Failed to remove Snap cache."
    sudo apt purge snapd -y || handle_error "Failed to remove Snap."

    log "Installing essential packages..." "$GR"
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
                nmap tzdata ufw \
                v4l2loopback-utils v4l2loopback-dkms \
                || handle_error "Failed to install essential packages."

    log "Installing CUDA and GPU libraries..." "$GR"
    sudo apt install -y cuda-minimal-build-11-4 \
                cuda-command-line-tools-11-4 \
                cuda-libraries-11-4 \
                libcudnn8 \
                libnvinfer8 libnvinfer-plugin8 \
                || handle_error "Failed to install CUDA and GPU libraries."

    log "Installing yq (YAML processor)..." "$GR"
    # Download and install `yq`, a command-line tool for processing YAML files
    wget https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_arm64.tar.gz -O - | tar xz && sudo mv yq_linux_arm64 /usr/bin/yq || handle_error "Failed to install yq."
    rm install-man-page.sh yq.1
}

# Docker setup
setup_docker() {
    log "Setting up Docker..." "$GR"
    #Remove any existing docker realted packages to avoid conflicts
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-buildx docker-ee docker-ce; do
        sudo apt-get remove -y "$pkg" || handle_error "Failed to remove old Docker packages."
    done

    sudo install -m 0755 -d /etc/apt/keyrings || handle_error "Failed to create Docker keyring directory."
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || handle_error "Failed to download Docker GPG key."
    sudo chmod a+r /etc/apt/keyrings/docker.asc || handle_error "Failed to set permissions on Docker GPG key."

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || handle_error "Failed to add Docker repository."

    sudo apt update -y || handle_error "Failed to update package list for Docker."

    #Install docker and related tools
    sudo apt-get install -y docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin \
                nvidia-docker2 \
                || handle_error "Failed to install Docker."

    sudo groupadd docker || log "Docker group already exists." "$GR"
    sudo usermod -aG docker "$USER" || handle_error "Failed to add user to Docker group."
    newgrp docker

    log "Testing Docker installation..." "$GR"
    docker run hello-world || handle_error "Docker test failed."

    log "Configuring NVIDIA Docker runtime..." "$GR"
    sudo nvidia-ctk runtime configure --runtime=docker || handle_error "Failed to configure NVIDIA Docker runtime."
    sudo systemctl restart docker || handle_error "Failed to restart Docker."
}

# Firewall setup
setup_firewall() {
    log "Configuring firewall rules..." "$GR"
    sudo ufw allow from 192.168.1.0/24 to any port 60000:61000 proto udp || handle_error "Failed to add firewall rule for ports 60000-61000."
    sudo ufw allow from 192.168.1.0/24 to any port 10000:60000 proto udp || handle_error "Failed to add firewall rule for ports 10000-60000."
    sudo ufw allow from 192.168.1.0/24 to any port 7501 proto udp || handle_error "Failed to add firewall rule for port 7501."
    sudo ufw allow from 192.168.1.0/24 to any port 7502 proto udp || handle_error "Failed to add firewall rule for port 7502."
    sudo ufw allow from 192.168.1.0/24 to any port 7503 proto udp || handle_error "Failed to add firewall rule for port 7503."
    sudo ufw allow from 192.168.1.0/24 to any port 3478 || handle_error "Failed to add firewall rule for port 3478."
    sudo ufw allow from 192.168.1.0/24 to any port 3479 || handle_error "Failed to add firewall rule for port 3479."
    sudo ufw status || handle_error "Failed to check firewall status."
}

# Directory setup
setup_directories() {
    log "Creating directories for ATI..." "$GR"
    sudo mkdir -p /opt/ati/{run,data,models,ref-data/map,uniflash,config,out} || handle_error "Failed to create directories."
    sudo chown -R ati:ati /opt/ati || handle_error "Failed to set directory permissions."
}

# Dynalog setup
dynalog() {
    log "Starting Dynalog setup..." "$GR"
    common_setup
    setup_docker
    setup_directories
    log "Dynalog setup complete!" "$GR"
}

# Advantech setup
advantech() {
    log "Starting Advantech setup..." "$GR"
    common_setup
    setup_firewall
    setup_docker
    setup_directories
    log "Advantech setup complete!" "$GR"
}

# Usage instructions
usage() {
    echo -e "
Usage: $0 [-adv] | [-dyn]
Options:
  -adv  -- For Advantech Boards
  -dyn  -- For Dynalog Boards

Description:
  This script sets up the system for Advantech or Dynalog boards.
  It installs essential packages, configures Docker, and sets up firewall rules.
"
}

# Main function to process command-line arguments
main() {
    if [ $# -eq 0 ]; then
        usage
    elif [ "$1" == "-adv" ]; then
        advantech
    elif [ "$1" == "-dyn" ]; then
        dynalog
    else
        usage
    fi
}

# Start the script
main "$@"


# Documentation for Packages
# =========================
# Essential Packages:
# ------------------
# alsa-utils: Tools for managing sound on Linux.
# apt-transport-https: Allows apt to use HTTPS for package downloads.
# avahi-daemon: Provides mDNS/DNS-SD (used for network discovery).
# bluez: Bluetooth protocol stack.
# bridge-utils: Tools for managing network bridges.
# ca-certificates: Common CA certificates for SSL.
# chrony: Time synchronization daemon.
# curl: Command-line tool for transferring data with URLs.
# gnupg-agent: GNU Privacy Guard agent.
# haveged: Entropy daemon for improving random number generation.
# isc-dhcp-server: DHCP server for IP address management.
# kmod: Tools for managing kernel modules.
# modemmanager: Mobile broadband modem management.
# netplan.io: Network configuration abstraction.
# net-tools: Basic networking tools (e.g., ifconfig, netstat).
# network-manager: Network connection management.
# openssh-server: SSH server for remote access.
# rsyslog: System logging daemon.
# software-properties-common: Tools for managing software repositories.
# systemd: System and service manager.
# udev: Device manager for the Linux kernel.
# qemu-user-static: QEMU user-mode emulation for running ARM binaries.
# language-pack-en: English language pack.
# htop: Interactive process viewer.
# mosh: Mobile shell for remote terminal access.
# rsync: File synchronization tool.
# tmux: Terminal multiplexer.
# vim: Text editor.
# wireless-tools: Tools for managing wireless networks.
# traceroute: Tool for tracing network paths.
# inetutils-ping: Ping tool for network diagnostics.
# nmap: Network exploration and security auditing tool.
# tzdata: Time zone data.
# ufw: Uncomplicated Firewall for managing firewall rules.
# v4l2loopback-utils: Tools for creating virtual video devices.
# v4l2loopback-dkms: Kernel module for virtual video devices.
#
# CUDA and GPU Libraries:
# ----------------------
# cuda-minimal-build-11-4: Minimal CUDA toolkit for GPU computing.
# cuda-command-line-tools-11-4: Command-line tools for CUDA.
# cuda-libraries-11-4: Libraries for CUDA development.
# libcudnn8: CUDA Deep Neural Network library.
# libnvinfer8: TensorRT library for deep learning inference.
# libnvinfer-plugin8: TensorRT plugins for deep learning.
#
# Docker Packages:
# ---------------
# docker-ce: Docker Community Edition.
# docker-ce-cli: Docker CLI tools.
# containerd.io: Container runtime.
# docker-buildx-plugin: Docker Buildx for multi-architecture builds.
# docker-compose-plugin: Docker Compose for multi-container applications.
# nvidia-docker2: NVIDIA Docker runtime for GPU support.