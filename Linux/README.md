# Custom Metrics Installation for Linux Instances
This document provides instructions for installing the custom-metrics-disk-memory-linux.sh script on any Linux instance. The script collects and publishes custom metrics for disk usage and memory usage to Amazon CloudWatch.

## Prerequisites
Before you begin, ensure you have the following:

* Access to the root account on the Linux instance.
* AWS CLI installed on your system.
* IAM user with necessary permissions to publish custom metrics to CloudWatch.
* Correct AWS account ID and region.

## Installation Steps
Switch to the root user:
```
sudo -i
```

Download the installation script:
```
curl -O https://raw.githubusercontent.com/cldcvr/automate-custom-metrics-installation/main/Linux/auto-install-custom-metrics-linux.sh
```

Run the installation script in the user data:

```
#!/bin/bash
curl -O https://raw.githubusercontent.com/cldcvr/automate-custom-metrics-installation/main/Linux/auto-install-custom-metrics-linux.sh
bash -x auto-install-custom-metrics-linux.sh > /var/log/auto-install-custom-metrics-linux.sh.log 2>&1
```

Alternatively, you can use the following base64-encoded script in the user data:
```
IyEvYmluL2Jhc2gKY3VybCAtTyBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vY2xkY3ZyL2F1dG9tYXRlLWN1c3RvbS1tZXRyaWNzLWluc3RhbGxhdGlvbi9tYWluL0xpbnV4L2F1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaApiYXNoIC14IGF1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaCA+IC92YXIvbG9nL2F1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaC5sb2cgMj4mMQo=
```
## Note
* The installation auto-install-custom-metrics-linux.sh script is generic and will run on any Linux instance.
* The installation auto-install-custom-metrics-linux.sh script includes all disks and mount points in the Linux system.
* The installation auto-install-custom-metrics-linux.sh script will take the DiskMetric and MemoryMetric arguments.

We recommend reviewing the script before running it to understand what it does.


# Create Alarms for Windows and Linux Instances on AWS EC2
The auto-custom-metrics-alarms.sh script creates CloudWatch alarms for custom metrics on an EC2 instance. The script checks whether the instance is running on Windows or Linux and then sets alarms for the available custom metrics accordingly. The alarms are created based on thresholds for certain metric values, and the script sends notifications to an SNS topic when an alarm is triggered.

## Prerequisites
Before you begin, ensure you have the following:

* AWS CLI installed on your system.
* IAM user with necessary permissions to create CloudWatch alarms and SNS topics.
* Correct AWS account ID and region.
* SNS topic ARN to which you want to send notifications.

## Usage
The script takes four arguments as input:

```
bash auto-custom-metrics-alarms.sh INSTANCE_ID ENVIRONMENT AWS_REGION SNS_ARN
```

* `INSTANCE_ID`: The ID of the EC2 instance for which you want to set alarms.
* `ENVIRONMENT`: The environment in which the instance is running (e.g., production, staging).
* `AWS_REGION`: The AWS region in which the instance is running.
* `SNS_ARN`: The Amazon Resource Name (ARN) of the SNS topic to which you want to send notifications.

It is recommended that you review the `auto-custom-metrics-alarms.sh` script before running it to understand what it does.