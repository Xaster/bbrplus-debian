#!/bin/bash

#Change working directory to home directory
cd

#Update system
apt update && apt full-upgrade -y

#Install build dependencies
apt install -y \
  wget \
  ca-certificates \
  build-essential \
  linux-headers-amd64 \
  | tee build-deps.txt

#Update CA Certificates
update-ca-certificates

#Build and install TCP-BBR Plus
mkdir bbrplus-debian
cd bbrplus-debian
wget https://raw.githubusercontent.com/Xaster/bbrplus-debian/master/Makefile
wget https://raw.githubusercontent.com/Xaster/bbrplus-debian/master/tcp_bbr_plus.c
make
make install
cd

#Config TCP-BBR Plus
[ ! -f /etc/sysctl.conf ] && touch /etc/sysctl.conf
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << \EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr_plus
EOF
sysctl -p

#Remove build dependencies
apt purge --auto-remove -y $(cat build-deps.txt | grep "Unpacking " | cut -d " " -f 2)
apt clean

#Remove temporary files
rm -rf \
  $HOME/bbrplus-debian \
  $HOME/build-deps.txt \
  /var/lib/apt/lists/*

#Check TCP-BBR Plus status
sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr_plus
if [ $? -eq 0 ];then
  lsmod | grep -q tcp_bbr_plus
  if [ $? -eq 0 ];then
    echo -e "\033[92m TCP-BBR Plus has been built and load. \033[0m"
  else
    echo -e "\033[91m TCP-BBR Plus load failed. \033[0m"
  fi
else
  echo -e "\033[91m TCP-BBR Plus not found. \033[0m"
fi
