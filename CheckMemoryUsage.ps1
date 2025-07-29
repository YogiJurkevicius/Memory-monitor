# =================== CONFIGURATION ===================
$threshold       = 80                             # Memory usage % to trigger alert
$smtpServer      = "smtp.yourdomain.local"        # SMTP server
$toEmail         = "Recipient@yourdomain.com"     # Recipient email
$fromEmail       = "Sender@yourdomain.com"        # Sender email
$checkIntervalMin = 30                            # Minimum minutes between alerts
$logDirectory    = "C:\Scripts\Logs"              # Directory to store logs
$alertLogFile    = "$logDirectory\LastAlert.txt"  # Timestamp record
# =====================================================

# Ensure log directory exists
if (-not (Test-Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory | Out-Null
}

# Get memory usage
$mem = Get-CimInstance -ClassName Win32_OperatingSystem
$usedMemPercent = [math]::Round((($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100)

# Get server name and IP
$hostname = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 `
       | Where-Object { $_.IPAddress -notlike '169.*' -and $_.InterfaceAlias -notlike '*Virtual*' -and $_.PrefixOrigin -ne 'WellKnown' } `
       | Select-Object -First 1 -ExpandProperty IPAddress)

# Time stamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$today = Get-Date -Format "yyyy-MM-dd"
$dailyLog = "$logDirectory\MemoryAlerts_$today.log"

# Check if threshold is breached
if ($usedMemPercent -ge $threshold) {
    # Check last alert time (if exists)
    $sendAlert = $true
    if (Test-Path $alertLogFile) {
        $lastAlertTime = Get-Content $alertLogFile | Out-String | Get-Date
        $minutesSinceLast = (New-TimeSpan -Start $lastAlertTime -End (Get-Date)).TotalMinutes
        if ($minutesSinceLast -lt $checkIntervalMin) {
            $sendAlert = $false
        }
    }

    if ($sendAlert) {
        $subject = "ALERT: High Memory Usage on $hostname ($ip)"
        $body = @"
Memory usage alert on server:

Server Name: $hostname
IP Address: $ip
Time: $timestamp
Memory Usage: $usedMemPercent%

Threshold: ${threshold}%
"@

        # Send email
        Send-MailMessage -To $toEmail -From $fromEmail -Subject $subject -Body $body -SmtpServer $smtpServer

        # Log to file
        $logLine = "$timestamp - $hostname ($ip): $usedMemPercent% used (alert sent)"
        Add-Content -Path $dailyLog -Value $logLine

        # Update last alert timestamp
        $timestamp | Out-File -FilePath $alertLogFile -Force
    } else {
        # Optional: write suppressed alert attempt to log
        $logLine = "$timestamp - $hostname ($ip): $usedMemPercent% used (alert suppressed)"
        Add-Content -Path $dailyLog -Value $logLine
    }
}
