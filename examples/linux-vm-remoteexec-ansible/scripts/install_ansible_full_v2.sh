#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible
echo "INFO: Started Installing Ansible..."
sudo yum -y install epel-release
sudo yum -y install ansible
sudo yum -y install python-pip pip
sudo pip install --upgrade pip
sudo pip install pywinrm

echo "INFO: Finished Installing Ansible."
