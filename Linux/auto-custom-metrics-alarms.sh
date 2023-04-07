#!/bin/bash

if [ $# -ne 5 ]; then
    echo "Usage: $0 INSTANCE_ID ENVIRONMENT AWS_REGION SNS_ARN PERCENTAGE_VALUE"
    exit 1
fi

# Check if the instance ID exists
if ! aws ec2 describe-instances --region $3 --instance-id "$1" >/dev/null 2>&1; then
    echo "Instance with ID $1 does not exist in your AWS account."
    exit 1
fi

# Check if SNS topic exists in AWS account
if ! aws sns list-topics --region $3 --output text | grep -q "$4"; then
    echo "SNS topic not found in AWS account. Please check the SNS ARN and try again."
    exit 1
fi

INST_ID="$1"
ENV="$2"
AWS_REGION="$3"
SNS_ARN="$4"
PERCENTAGE_VALUE="$5"

echo "Checking custom metrics associated with $INST_ID"
if [ -z "$(aws ec2 describe-instances --instance-id $INST_ID --region $AWS_REGION --output text --query 'Reservations[*].Instances[*].Platform')" ]; then
        echo "Instance Platform is Linux"
        INST_PLATFORM="Linux"
else
        echo "Instance Platform is Windows"
        INST_PLATFORM="Windows"
fi

echo "Checking for available Custom Metrics"

setDiskAlarmsLinux() {
    # Main logic #setDiskAlarms "$SNS_ARN" "$NAMESPACE_ID" "$METRIC_NAME""Utilization"
    aws cloudwatch list-metrics --region $AWS_REGION --output text --query 'Metrics[?Namespace==`'"$2"'`].Dimensions' | tr -s '\t' ':' | paste -d, - - - | grep "$INST_ID" | while read -r DISK_DIMENSIONS; do
        DRIVE_ID="$(echo $DISK_DIMENSIONS | awk -F: '{print $NF}')"
        MOUNT_PATH="$(echo $DISK_DIMENSIONS | awk -F'[,:]+' '{print $2}')"
        INST_NAME="$(aws ec2 describe-instances --instance-ids $INST_ID --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)"

        # Loop through percentage values
        for PERCENTAGE in $PERCENTAGE_VALUE; do
            # Build alarm description
            ALARM_NAME="$ENV-$INST_NAME-$INST_ID-$DRIVE_ID-$3-$PERCENTAGE"
            ALARM_DESCRIPTION="$ENV $INST_NAME $INST_ID $DRIVE_ID: $3 > $PERCENTAGE%"

            # Create alarm using AWS CLI
            aws cloudwatch put-metric-alarm \
                --alarm-name "$ALARM_NAME" \
                --alarm-description "$ALARM_DESCRIPTION" \
                --actions-enabled \
                --alarm-actions "$1" \
                --namespace "$2" \
                --metric-name "$3" \
                --dimensions Name=InstanceId,Value="$INST_ID" Name=Filesystem,Value="$DRIVE_ID" Name=MountPath,Value="$MOUNT_PATH" \
                --period 300 \
                --evaluation-periods 1 \
                --statistic Average \
                --threshold "$PERCENTAGE" \
                --comparison-operator GreaterThanOrEqualToThreshold \
                --unit Percent \
                --region $AWS_REGION
        done
    done
}

setMemoryAlarms() {
    # Main logic
    aws cloudwatch list-metrics --region $AWS_REGION --output text --query 'Metrics[?Namespace==`'"$2"'`].Dimensions[].Value' | tr -s '\t' '\n' | grep -e "$INST_ID" | while read -r INST_ID; do
        IFS=,
        aws ec2 describe-instances --instance-ids "$INST_ID" --region $AWS_REGION --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text | while read -r INST_NAME; do
            for PERCENTAGE in $PERCENTAGE_VALUE; do
                ALARM_DESCRIPTION="$ENV $INST_NAME $INST_ID $3 > $PERCENTAGE%"
                aws cloudwatch put-metric-alarm \
                    --alarm-name "$ENV-$INST_NAME-$INST_ID-$3-$PERCENTAGE" \
                    --alarm-description "$ALARM_DESCRIPTION" \
                    --actions-enabled \
                    --alarm-actions "$1" \
                    --namespace "$2" \
                    --metric-name "$3" \
                    --dimensions Name=InstanceId,Value="$INST_ID" \
                    --evaluation-periods 1 \
                    --comparison-operator GreaterThanOrEqualToThreshold \
                    --period 300 \
                    --statistic Average \
                    --threshold "$PERCENTAGE" \
                    --unit Percent \
                    --region $AWS_REGION
            done
        done
    done
}


if [ "$INST_PLATFORM" == "Windows" ]; then
        for NAMESPACE_ID in "$INST_PLATFORM"/Disk "$INST_PLATFORM"/Memory; do
                export METRIC_NAME="$(echo "$NAMESPACE_ID" | cut -d/ -f2)"
                if aws cloudwatch list-metrics --region $AWS_REGION --output text --query 'Metrics[?Namespace==`'"$NAMESPACE_ID"'`].Dimensions[].Value' | tr -s '\t' '\n' | grep -q "$INST_ID"; then
                        echo "Custom Metrics present for $NAMESPACE_ID; Setting Alerts"
                        if [ "$METRIC_NAME" == "Disk" ]; then
                                setDiskAlarmsWindows "$SNS_ARN" "$NAMESPACE_ID" "$METRIC_NAME""Utilization"
                        elif [ "$METRIC_NAME" == "Memory" ]; then
                                setMemoryAlarms "$SNS_ARN" "$NAMESPACE_ID" "$METRIC_NAME""Utilization"
                        fi
                else
                        echo "Custom Metrics for $METRIC_NAME are not set on $INST_ID; Do it ASAP."
                fi
        done
elif [[ "$INST_PLATFORM" == "Linux" ]]; then
        for NAMESPACE_ID in "$INST_PLATFORM"/Disk "$INST_PLATFORM"/Memory; do
                export METRIC_NAME="$(echo "$NAMESPACE_ID" | cut -d/ -f2)"
                if aws cloudwatch list-metrics --region $AWS_REGION --output text --query 'Metrics[?Namespace==`'"$NAMESPACE_ID"'`].Dimensions[].Value' | tr -s '\t' '\n' | grep -q "$INST_ID"; then
                        echo "Custom Metrics present for $NAMESPACE_ID; Setting Alerts"
                        if [ "$METRIC_NAME" == "Disk" ]; then
                                setDiskAlarmsLinux "$SNS_ARN" "$NAMESPACE_ID" "$METRIC_NAME""Utilization"
                        elif [ "$METRIC_NAME" == "Memory" ]; then
                                setMemoryAlarms "$SNS_ARN" "$NAMESPACE_ID" "$METRIC_NAME""Utilization"
                        fi
                else
                        echo "Custom Metrics for $METRIC_NAME are not set on $INST_ID; Do it ASAP."
                fi
        done
fi