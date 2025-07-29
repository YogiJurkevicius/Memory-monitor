# WARNING: Only run on a test system or during a maintenance window!

# This allocates approximately 1 GB of memory
$memoryHog = @()
for ($i = 0; $i -lt 500000; $i++) {
    $memoryHog += "X" * 1024
}
