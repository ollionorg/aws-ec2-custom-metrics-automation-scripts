# Custom Metrics Installation for Linux Instances
This document provides instructions for installing the `auto-install-custom-metrics-linux.sh` script on any Linux instance. The script collects and publishes custom metrics for disk usage and memory usage to Amazon CloudWatch.

## Note: 
* The `auto-install-custom-metrics-linux.sh` script supports both IMDSv1 and IMDSv2. It is recommended to use IMDSv2 for improved security.

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
curl -O https://raw.githubusercontent.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/main/Linux/auto-install-custom-metrics-linux.sh
```

Run the installation script in the user data:

```
#!/bin/bash
curl -O https://raw.githubusercontent.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/main/Linux/auto-install-custom-metrics-linux.sh
bash -x auto-install-custom-metrics-linux.sh > /var/log/auto-install-custom-metrics-linux.sh.log 2>&1
```

Alternatively, you can use the following base64-encoded script in the user data:

```
IyEvYmluL2Jhc2gKY3VybCAtTyBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vY2xkY3ZyL2F1dG9tYXRlLWN1c3RvbS1tZXRyaWNzLWluc3RhbGxhdGlvbi9tYWluL0xpbnV4L2F1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaApiYXNoIC14IGF1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaCA+IC92YXIvbG9nL2F1dG8taW5zdGFsbC1jdXN0b20tbWV0cmljcy1saW51eC5zaC5sb2cgMj4mMQo=
```

## Note
* The script is generic (will run on any Linux instance)
* This script will include all the disks and mount points in the linux system.
* The same script will take argument `MemoryMetric` and `DiskMetric`.
* The `auto-install-custom-metrics-linux.sh` script will implement all the steps above, automatically.

We recommend reviewing the script before running it to understand what it does.


# Create Alarms for Windows and Linux Instances on AWS EC2
The `auto-custom-metrics-alarms.sh` script creates CloudWatch alarms for custom metrics on an EC2 instance. The script checks whether the instance is running on Windows or Linux and then sets alarms for the available custom metrics accordingly. The alarms are created based on thresholds for certain metric values, and the script sends notifications to an SNS topic when an alarm is triggered.

## Prerequisites
Before you begin, ensure you have the following:

* AWS CLI installed on your system.
* IAM user with necessary permissions to create CloudWatch alarms and SNS topics.
* Correct AWS account ID and region.
* SNS topic ARN to which you want to send notifications.

## Usage
The script takes four arguments as input:

```
bash auto-custom-metrics-alarms.sh INSTANCE_ID ENVIRONMENT AWS_REGION SNS_ARN PERCENTAGE_VALUE
```

* `INSTANCE_ID`: The ID of the EC2 instance for which you want to set alarms.
* `ENVIRONMENT`: The environment in which the instance is running (e.g., production, staging).
* `AWS_REGION`: The AWS region in which the instance is running.
* `SNS_ARN`: The Amazon Resource Name (ARN) of the SNS topic to which you want to send notifications.
* `PERCENTAGE_VALUE`: The percentage threshold for CPU utilization that triggers the alarm. When the average CPU utilization of the instance exceeds this value for a specified period of time, the alarm will be triggered and a notification will be sent to the specified SNS topic.

It is recommended that you review the `auto-custom-metrics-alarms.sh` script before running it to understand what it does.