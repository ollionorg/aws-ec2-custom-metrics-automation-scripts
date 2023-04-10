#!/bin/bash

HTTP_ERROR_CODE=`curl -s -o /dev/null -w "%{http_code}"  http://169.254.169.254/`

if [ $HTTP_ERROR_CODE  == 401 ]; then
	TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
	export AWS_DEFAULT_REGION="$(curl -H "X-aws-ec2-metadata-token: $TOKEN"  -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//g')"
	export AWS_DEFAULT_OUTPUT="text"
	INST_ID="$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"

else
	export AWS_DEFAULT_REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//g')"
	export AWS_DEFAULT_OUTPUT="text"
	INST_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
fi

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"$PATH"
alias aws=''`which aws`' --output text'
shopt -s expand_aliases

MemoryMetric() {
vmstat -s | sed -e 's/^[ \t]*//' | cut -d' ' -f1,3- | tr -s ' ' ',' | grep -e 'total,memory' -e 'free,memory' -e 'buffer,memory' -e 'swap,cache' | awk -F, '{print $1/1024","$2" "$3}' > /tmp/mem-usage.csv
MemTotal="$(cat /tmp/mem-usage.csv | grep -e 'total memory' | awk -F, '{print $1}')"
MemFree="$(cat /tmp/mem-usage.csv | grep -e 'free memory' | awk -F, '{print $1}')"
Buffers="$(cat /tmp/mem-usage.csv | grep -e 'buffer memory' | awk -F, '{print $1}')"
Cached="$(cat /tmp/mem-usage.csv | grep -e 'swap cache' | awk -F, '{print $1}')"
TotalMemFree="$(bc -l <<< $MemFree+$Buffers+$Cached)"
TotalMemUsed="$(bc -l <<< $MemTotal-$TotalMemFree)"
mem="$(bc <<< "scale=2; $TotalMemUsed*100/$MemTotal")"
rm -f /tmp/mem-usage.csv
#mem=$(bc <<< "scale=2; $(free -m  | grep ^Mem | awk '{print $3/$2*100}')/1")
aws cloudwatch put-metric-data \
	--metric-name "MemoryUtilization" \
	--unit Percent \
	--value "$mem" \
	--dimensions InstanceId="$INST_ID" \
	--namespace Linux/Memory
}

DiskMetric(){
aws cloudwatch put-metric-data \
	--metric-name "DiskUtilization" \
	--unit Percent \
	--value "$2" \
	--dimensions InstanceId="$INST_ID",Filesystem="$1",MountPath="$3" \
	--namespace Linux/Disk
}

###############################################################################################################

if [[ $1 == DiskMetric ]]; then
	# Starting Disk Logic
	# /dev/sda2 62 /VM
	# $1 = /dev/sda2
	# $2 = 62
	# $3 = /VM
	df -h --output=source,pcent,target | grep "^/.*" | grep -v "^/tmp" | grep -v "^/run" | grep -v "^/dev/shm" | grep -v "^/sys" | grep -v "^/proc" | grep -v "/snap/" | grep -v "efi" | awk '{print $1, $2, $3}' | tr -d '%' | while read line; do
                DiskMetric $line
        done
elif [[ $1 == MemoryMetric ]]; then
        MemoryMetric
fi

unalias aws