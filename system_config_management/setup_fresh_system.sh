#!/bin/bash

################################################################################
## Perform system update
################################################################################
sudo apt update -y && sudo apt dist-upgrade -y

################################################################################
## Remove snapd
################################################################################
sudo rm -rf /var/cache/snapd/
sudo apt autoremove --purge snapd -y
rm -rf ~/snap

################################################################################
# Install dependency software packages
##      vim
##      tmux
##      git
##      build-essential
##      sysstat
##      htop
##      ca-certificates
##      curltmux
##      gnupg
##      lsb-release
################################################################################

sudo apt install -y vim \
                    tmux \
		    exuberant-ctags \
                    git \
                    build-essential \
                    sysstat \
                    htop \
                    ca-certificates \
                    curl \
                    gnupg \
                    lsb-release

################################################################################
## Docker Engine (docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin,
## docker-compose-plugindocker)
################################################################################

## Clean up old docker installation
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Docker GPG Key setup
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Update apt repo 
sudo apt update -y

## Install the latest version of Docker Engine
sudo apt-get install -y docker-ce \
                        docker-ce-cli \
                        containerd.io \
                        docker-buildx-plugin \
                        docker-compose-plugin

# Create the `docker` group
sudo groupadd docker
## Add user to docker group
sudo usermod -aG docker $USER
## Activate changes to the group
newgrp docker

################################################################################
## TODO: Install Rust dependencies
################################################################################

################################################################################
## Install GoLang dependencies
################################################################################
mkdir -p ~/Downloads/DELETE_LATER/ && cd ~/Downloads/DELETE_LATER/
wget https://go.dev/dl/go1.24.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mkdir -p /usr/local/go
sudo tar -C /usr/local -xzf go1.24.1.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

echo "------------------------ Checking GoLang Version ------------------------"
/usr/local/go/bin/go version
echo "---------------------- GoLang Configured --------------------------------"
rm -rf ~/Downloads/DELETE_LATER/

################################################################################
## TODO: Install minikube/kubectl and associated dependencies
################################################################################

################################################################################
## Setup desired directory structures
################################################################################
mkdir -p  ~/.vim \
          ~/imp_backups/sys_configs
