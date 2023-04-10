# Steps to install Custom Metrics on Windows Instances

### Common Steps
The following steps can be executed in Powershell (much faster):

1. Install aws cli tools for windows (64 Bit):
```sh
C:\> msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

aws --version
```

2. Allow scripts to be executed in powershell:
```sh
Set-ExecutionPolicy Unrestricted
```

3. Please configure the Cloudwatch credentials on the server and ensure that the region is set correctly.:
```sh
aws configure
```
4. Enter the required fields carefully.

5. Create script directory specific to cloudcover:
```powershell
new-item c:\cloudcover\scripts\ -itemtype directory
```
---
## Disk Metrics
1. Download the script `custom-metrics-disk-windows.ps1` from Github to `c:\cloudcover\scripts\` folder, or use the following command:
```powershell
(New-Object System.Net.WebClient).DownloadFile(“https://raw.githubusercontent.com/cldcvr/automate-custom-metrics-installation/main/Windows/custom-metrics-disk-windows.ps1”,”c:\cloudcover\scripts\custom-metrics-disk-windows.ps1")
```
2. Test the script by running it a few times.
```powershell
&  c:\cloudcover\scripts\custom-metrics-disk-windows.ps1
```

3. Create a scheduler for script to run on 10 minutes interval:
```powershell
schtasks /create /sc minute /mo 10 /tn DiskUsageReport /tr "powershell.exe -WindowStyle Hidden -NoLogo -File c:\cloudcover\scripts\custom-metrics-disk-windows.ps1"
```
---
### Memory Metrics
1. Download the script `custom-metrics-memory-windows.ps1` from Github to `c:\cloudcover\scripts\` folder, or use the following command:
```powershell
(New-Object System.Net.WebClient).DownloadFile(“https://raw.githubusercontent.com/cldcvr/automate-custom-metrics-installation/main/Windows/custom-metrics-memory-windows.ps1”,”c:\cloudcover\scripts\custom-metrics-memory-windows.ps1")
```
2. Test the script by running it in powershell (2-3 times):
```powershell
&  c:\cloudcover\scripts\custom-metrics-memory-windows.ps1
```
3. Create a scheduler for script to run for 1 minute:
```powershell
schtasks /create /sc minute /mo 1 /tn MemoryUsageReport /tr "powershell.exe -WindowStyle Hidden -NoLogo -File c:\cloudcover\scripts\custom-metrics-memory-windows.ps1"
```
---
**NOTES:**
* The script is generic (will run on any windows instance).
* The script `custom-metrics-disk-windows.ps1` covers all disks on a windows instance (no hardcoding needed).
* Instance Role is assumed to be attached with relevant permissions.
