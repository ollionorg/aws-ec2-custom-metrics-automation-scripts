# Steps to Install Custom Metrics on Windows Instances

The `custom-metrics-disk-windows.ps1` and `custom-metrics-memory-windows.ps1` scripts collect and publish custom metrics for disk and memory usage on Windows EC2 instances in AWS CloudWatch. it is work on both `IMDSv1` and `IMDSv2`, but it's recommended to use `IMDSv2` for better security and performance. The scripts can be scheduled to run and are part of the steps to install custom metrics on Windows instances in AWS CloudWatch.

### Common Steps
The following steps can be executed in Powershell (much faster): 

* Install aws cli tools for windows (64 Bit):
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Close PowerShell and reopen it. Then, run the command below to verify that AWS CLI has been successfully installed:

```powershell
aws --version
```

* Allow scripts to be executed in PowerShell by running the following command:

```powershell
Set-ExecutionPolicy Unrestricted
```
This step is required to allow the PowerShell scripts to run on the Windows instance. You will be prompted to enter 'Y' to confirm the change. This command changes the PowerShell execution policy to `Unrestricted`, which means that any script can be executed on the system. This step can be skipped if the execution policy is already set to `Unrestricted`.

* Configure the AWS CLI credentials on the Windows instance by running the following command:
```powershell
aws configure
```
After running the aws configure command, you will be prompted to enter the AWS access key ID, secret access key, default region name, and default output format.
You can enter the correct region name for your AWS account. For example, if you want to use the `us-west-2` region, you can enter `us-west-2` when prompted for the default region name.

* Create a directory for the scripts by running the following command:
```powershell
new-item c:\cloudcover\scripts\ -itemtype directory
```

---
## Disk Metrics
* Download the script `custom-metrics-disk-windows.ps1` from Github to `c:\cloudcover\scripts\` folder, or use the following command:
```powershell
(New-Object System.Net.WebClient).DownloadFile(“https://raw.githubusercontent.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/main/Windows/custom-metrics-disk-windows.ps1”,”c:\cloudcover\scripts\custom-metrics-disk-windows.ps1")
```

* Test the script by running it a few times.
```powershell
&  c:\cloudcover\scripts\custom-metrics-disk-windows.ps1
```

* Create a scheduler for script to run on 10 minutes interval:
```powershell
schtasks /create /sc minute /mo 10 /tn DiskUsageReport /tr "powershell.exe -WindowStyle Hidden -NoLogo -File c:\cloudcover\scripts\custom-metrics-disk-windows.ps1"
```

---
### Memory Metrics
* Download the script `custom-metrics-memory-windows.ps1` from Github to `c:\cloudcover\scripts\` folder, or use the following command:
```powershell
(New-Object System.Net.WebClient).DownloadFile(“https://raw.githubusercontent.com/cldcvr/aws-ec2-custom-metrics-automation-scripts/main/Windows/custom-metrics-memory-windows.ps1”,”c:\cloudcover\scripts\custom-metrics-memory-windows.ps1")
```

* Test the script by running it in powershell (2-3 times):
```powershell
&  c:\cloudcover\scripts\custom-metrics-memory-windows.ps1
```

* Create a scheduler for script to run for 1 minute:
```powershell
schtasks /create /sc minute /mo 1 /tn MemoryUsageReport /tr "powershell.exe -WindowStyle Hidden -NoLogo -File c:\cloudcover\scripts\custom-metrics-memory-windows.ps1"
```

---
**NOTES:**
* The script is generic (will run on any windows instance).
* The script `custom-metrics-disk-windows.ps1` covers all disks on a windows instance (no hardcoding needed).
* Instance Role is assumed to be attached with relevant permissions.
* Make sure the IAM role attached to the instance has permission to use `IMDSv2`. This is required for newer instance types that use `IMDSv2` by default. If the IAM role attached to the instance does not have permission to use IMDSv2, you may need to add the `ec2:DescribeInstanceMetadata` permission to the IAM role.
