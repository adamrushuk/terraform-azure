#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible
echo "INFO: Started Installing Ansible..."

# Install Python and Python tools
sudo yum -y install git python python-devel python-setuptools python-setuptools-devel

# Install Pip with easy_install
sudo easy_install pip

# Make sure setuptools are installed crrectly.
sudo pip install setuptools --no-use-wheel --upgrade

# Install Ansible
sudo pip install ansible

# Needed for WinRM comms
sudo pip install --upgrade pip
sudo pip install pywinrm

# Make our ansible working directory ready to copy files to
mkdir /home/$USER/ansible-config

echo "INFO: Finished Installing Ansible."
