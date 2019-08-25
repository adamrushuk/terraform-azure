#!/bin/bash

# Install common utils
echo "INFO: Started Installing Extra Packages Repo and useful utils..."
yum -y install epel-release --enablerepo=extras
yum -y update
yum -y install tree git vim bash-completion
# yum -y install python-pip
# pip install pip --upgrade

# Testing Python 3
yum -y install python36 python36-pip
pip install --upgrade pip setuptools
echo "INFO: Finished Installing Extra Packages Repo and useful utils."
