#!/bin/bash
# Install terraform on linux systems
# Authors: Suraj Budha Thoki
# Date: 2024-06-10
# Version: 1.0

set -e
os_family="unknown"

# Determine OS family
if [[ -f /etc/os-release ]]
  then
  echo "test"
  os_family=$(cat /etc/os-release | grep ^NAME | cut -d '"' -f2 | tr '[:upper:]' '[:lower:]')
elif [[ -f /etc/redhat-release ]]
  then
  os_family="redhat"
fi

echo "$os_family"

if [[ "$os_family" == *"ubuntu"* || "$os_family" == *"debian"* ]]
  then
    echo "Installing libvirt on Ubuntu/Debian"
    sudo apt-get update
    sudo apt-get install -y libvirt-daemon-system libvirt-clients qemu-kvm virtinst bridge-utils virt-manager
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    sudo usermod -aG libvirt $USER
    echo "Libvirt installation completed on Ubuntu/Debian"
elif [[ "$os_family" == *"redhat"* || "$os_family" == *"centos"* || "$os_family" == *"fedora"* ]]
  then
    echo "Installing libvirt on RedHat/CentOS/Fedora"
    sudo yum install -y libvirt libvirt-daemon-kvm qemu-kvm virt-install bridge-utils virt-manager
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    sudo usermod -aG libvirt $USER
    echo "Libvirt installation completed on RedHat/CentOS/Fedora"
else
    echo "This script is intended for Ubuntu/Debian/Redhat systems only."
    exit 1
fi