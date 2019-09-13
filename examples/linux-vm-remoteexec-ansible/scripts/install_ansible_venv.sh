#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install Ansible dependencies
echo "INFO: Started Installing Ansible..."
sudo yum check-update
sudo yum -y install gcc libffi-devel python-devel openssl-devel epel-release
sudo yum -y install python36 python36-pip

# Configure virtual environment for Python 3 / Ansible 2.8.4
python36 --version
mkdir -p ~/python-env
cd ~/python-env
python36 -m venv ansible2.8.4
source ~/python-env/ansible2.8.4/bin/activate

# Upgrade pip
pip3 -V
sudo pip3 install --upgrade pip setuptools
pip3 -V

# Install Ansible and pywinrm (for Windows support)
pip install ansible[azure]==2.8.4
pip install pywinrm
echo "INFO: Finished Installing Ansible."
