$instance_id = $null

# Try IMDSv2 first
try {
  $token = (Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token)
  $instance_id = (Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/instance-id)
}
catch {
  Write-Host "Failed to authenticate with IMDSv2, falling back to IMDSv1."
}

# If IMDSv2 failed, use IMDSv1
if ($instance_id -eq $null) {
  $instance_id = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/instance-id).Content
}

aws cloudwatch put-metric-data --namespace Windows/Memory --dimension InstanceId=$instance_id --unit Percent --value "$(Get-WmiObject win32_operatingsystem -ComputerName $env:computername | Foreach {"{0:N0}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)})" --metric-name "MemoryUtilization"