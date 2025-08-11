# Memory-monitor
# Windows Server Memory Monitor & Alert System

This project includes PowerShell scripts to monitor a Windows Server's memory usage and send alert emails when thresholds are exceeded. It also includes a helper script to simulate high memory usage for testing purposes.

---

## Scripts

### `CheckMemoryUsage.ps1`
Monitors system memory usage and sends alerts when usage exceeds a defined threshold. Alerts are logged locally and are suppressed for a configurable time window to prevent email flooding.

#### Configuration

Edit the variables at the top of the script:

| Variable             | Description                                         |
|----------------------|-----------------------------------------------------|
| `$threshold`         | Memory usage % to trigger alert (e.g., `80`)        |
| `$smtpServer`        | SMTP server address                                 |
| `$toEmail`           | Recipient email address                             |
| `$fromEmail`         | Sender email address                                |
| `$checkIntervalMin`  | Minimum minutes between alerts                      |
| `$logDirectory`      | Folder to store daily logs                          |

#### Example Alert Email

**Subject:**
```
ALERT: High Memory Usage on SERVER01 (192.168.1.10)
```

**Body:**
```
Memory usage alert on server:

Server Name: SERVER01
IP Address: 192.168.1.10
Time: 2025-07-29 14:03:21
Memory Usage: 92%

Threshold: 80%
```

#### Logging

- Daily log file:
  ```
  C:\Scripts\Logs\MemoryAlerts_YYYY-MM-DD.log
  ```
- Last alert timestamp:
  ```
  C:\Scripts\Logs\LastAlert.txt
  ```
---
#### TaskScheduler.xml

Uses Windows Task Scheduler to run the script regularly. Starts when first created, Rebooted, and every morning and then runs every 5 minutes afterwards.

---
###  `MemoryHog.ps1`

Used to simulate high memory usage (~2 GB) to test the alerting system.

#### Script
```powershell
# WARNING: Only run on a test system or during a maintenance window!

# This allocates approximately 2 GB of RAM
$memoryHog = @()
for ($i = 0; $i -lt 1000000; $i++) {
    $memoryHog += "X" * 1024
}
```

#### To Stop or Release Memory

- Press `Ctrl + C` in PowerShell
- Or run:
  ```powershell
  $memoryHog = $null
  [System.GC]::Collect()
  ```

---

## Warnings

- Do **not** run `MemoryHog.ps1` on a production system.
- Ensure your SMTP server allows sending from the configured `FromEmail`.
- Monitor your logs if left running for long periods.

---
