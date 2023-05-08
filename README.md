![Logo](./img/cldcvr_logo.png)


# AWS EC2 Custom Metrics Automation Scripts

This repository contains a set of scripts that automate the collection and publishing of custom metrics for Amazon EC2 instances running on Windows and Linux operating systems. These scripts use `cron`, the AWS CLI, and PutMetric to send custom metrics to CloudWatch. Additionally, there are scripts that create alarms with thresholds of 75% and 90% (which can be changed) for Memory and Disk metrics.

The custom metrics collected and published by these scripts are:

- Memory usage (in percent)
- Disk usage (in percent)

## Prerequisites

Before you can use these scripts, you'll need to ensure that:

- Your EC2 instances are running on either Windows or Linux operating systems.
- You have installed and configured the AWS CLI on your instances. See [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) in the AWS documentation for instructions on how to install and configure the CLI on your instances.
- You have set up IAM permissions for the AWS CLI to access the CloudWatch service. See [Creating a Role for an Amazon EC2 Instance to Access AWS CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html) in the AWS documentation for instructions on how to set up these permissions.
- Your instances are running with Instance Metadata Service version 2 (IMDSv2) enabled. These scripts are compatible with IMDSv2 (recommended) and will also work with earlier versions (**not recommended**).

## Usage

To use these scripts, simply download or clone the repository to your local machine. Then, navigate to the `scripts` directory and select the appropriate subdirectory for your operating system (`linux` or `windows`). Each subdirectory contains a set of scripts that you can use to collect and publish custom metrics to CloudWatch.

- For linux click [here](https://github.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/blob/main/Linux/README.md)
- For windows click [here](https://github.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/blob/main/Windows/README.md) 