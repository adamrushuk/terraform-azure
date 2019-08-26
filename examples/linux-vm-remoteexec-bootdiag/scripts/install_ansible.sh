#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible dependencies
echo "INFO: Started Installing Ansible..."
sudo yum check-update; sudo yum install -y gcc libffi-devel python-devel openssl-devel epel-release
sudo yum install -y python-pip python-wheel

# Configure virtual environment for Python 3 / Ansible 2.8.4
python36 --version
mkdir -p ~/python-env
cd ~/python-env
python36 -m venv ansible2.8.4
source ~/python-env/ansible2.8.4/bin/activate
pip -V

# Install Ansible and pywinrm (for Windows support)
pip install --upgrade pip setuptools
pip install ansible[azure]==2.8.4
pip install pywinrm

echo "INFO: Finished Installing Ansible."
