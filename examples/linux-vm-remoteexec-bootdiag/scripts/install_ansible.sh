#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible
echo "INFO: Started Installing Ansible..."
sudo pip install --upgrade ansible
sudo pip install pywinrm
echo "INFO: Finished Installing Ansible."
