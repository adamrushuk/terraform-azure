#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible
echo "INFO: Started Installing Ansible..."
sudo yum check-update; sudo yum install -y gcc libffi-devel python-devel openssl-devel epel-release
sudo yum install -y python-pip python-wheel

sudo pip install ansible[azure]
sudo pip install pywinrm
echo "INFO: Finished Installing Ansible."
