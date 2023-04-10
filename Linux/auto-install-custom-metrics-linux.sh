#!/bin/bash

# This is a script to setup custom metrics on Linux machines.
# Prerequisites:
# 1. This script must be run as root user, not sudo user.
# 2. AWS CLI must be installed and AWS credentials must be set up.

# Installing required packages
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:"$PATH"

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get 2> /dev/null)

if [[ ! -z $YUM_CMD ]]; then
  yum install -y bc dos2unix unzip cronie cronie-anacron chrony
elif [[ ! -z $APT_GET_CMD ]]; then
  apt-get update &> /dev/null
  apt-get install -y bc dos2unix unzip chrony
else
  echo "Error: Can't install packages."
  exit 1
fi

# Installing AWS CLI if not already installed
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  sudo ./aws/install
fi

# Setting up AWS CLI configuration
HTTP_ERROR_CODE=$(curl --fail -s -o /dev/null -w "%{http_code}" http://169.254.169.254/)
if [ "$HTTP_ERROR_CODE" == 401 ]; then
  TOKEN=$(curl --fail -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  AWS_DEFAULT_REGION="$(curl --fail -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//g')"
else
  AWS_DEFAULT_REGION="$(curl --fail -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//g')"
fi

aws configure set default.region "$AWS_DEFAULT_REGION"
export AWS_DEFAULT_OUTPUT="text"

# Downloading the scripts
mkdir -p /root/scripts/
cd /root/scripts/
rm -f custom-metrics-disk-memory-linux.sh
curl -o custom-metrics-disk-memory-linux.sh https://raw.githubusercontent.com/cldcvr/automate-custom-metrics-installation/main/Linux/custom-metrics-disk-memory-linux.sh
dos2unix custom-metrics-disk-memory-linux.sh
chmod +x custom-metrics-disk-memory-linux.sh

#Amazon Time Sync Service
if [[ ! -z $YUM_CMD ]]; then
  # Check if Amazon Time Sync Service is already configured
  if grep -q "169.254.169.123" /etc/chrony.conf; then
    echo "Amazon Time Sync Service already configured."
  else
    sudo sh -c 'echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf'
    echo "Amazon Time Sync Service configured successfully."
  fi
elif [[ ! -z $APT_GET_CMD ]]; then
  # Check if Amazon Time Sync Service is already configured
  if grep -q "169.254.169.123" /etc/chrony/chrony.conf; then
    echo "Amazon Time Sync Service already configured."
  else
    # Configure Chrony to use Amazon Time Sync Service
    sudo sh -c 'echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony/chrony.conf'
    echo "Amazon Time Sync Service configured successfully."
  fi
else
  echo "Unsupported package manager."
fi


# Remove existing (defunct) crontabs
(crontab -l | grep -v -e 'DiskMetric' -e 'MemoryMetric' -e 'ntpdate' -e 'chrony') | crontab -

# Setting up updated cron jobs
crontab -l | { cat; echo -e "* * * * *\t/bin/bash /root/scripts/custom-metrics-disk-memory-linux.sh DiskMetric"; } | crontab -
crontab -l | { cat; echo -e "* * * * *\t/bin/bash /root/scripts/custom-metrics-disk-memory-linux.sh MemoryMetric"; } | crontab -

# Restart Chrony service
if [[ ! -z $YUM_CMD ]]; then
    sudo systemctl restart chronyd.service
elif [[ ! -z $APT_GET_CMD ]]; then
    sudo systemctl restart cron
else
    echo "Unsupported package manager"
fi

# Enable the crond service to start at boot
if [[ ! -z $YUM_CMD ]]; then
    sudo systemctl enable crond.service
elif [[ ! -z $APT_GET_CMD ]]; then
    sudo systemctl enable cron.service
else
    echo "Unsupported package manager"
fi

# Check output
clear
crontab -l
sleep 30