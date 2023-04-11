function ToArray
{
  begin
  {
    $output = @();
  }
  process
  {
    $output += $_;
  }
  end
  {
    return ,$output;
  }
}

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

$disklist=Get-WmiObject -Class Win32_LogicalDisk | Select-Object -Property DeviceID, @{Name='UsedPercent';Expression={(100-($_.FreeSpace/$_.Size)*100)}} |ToArray

for ($j=0;$j -lt $disklist.Count ; $j++)
{
    aws cloudwatch put-metric-data --namespace "Windows/Disk" --metric-name DiskUtilization --unit Percent --value $disklist[$j].UsedPercent --dimensions "InstanceId=$instance_id,Drive=$($disklist[$j].DeviceID)"
}