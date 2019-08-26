#!/bin/bash
# Ensure EOL is LF; not the windows CRLF

# Install common utils
echo "INFO: Started Installing Extra Packages Repo and useful utils..."
sudo yum -y install epel-release --enablerepo=extras
sudo yum -y update
sudo yum -y install tree git vim bash-completion
# yum -y install python-pip
# pip install pip --upgrade

# Testing Python 3
sudo yum -y install python36 python36-pip
sudo pip install --upgrade pip setuptools
echo "INFO: Finished Installing Extra Packages Repo and useful utils."
