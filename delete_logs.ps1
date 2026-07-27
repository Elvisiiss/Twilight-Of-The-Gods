$gameDir = Join-Path $PSScriptRoot "game"
$dryRun = $false

if ($args.Count -gt 0 -and $args[0] -eq "-dryrun") {
    $dryRun = $true
    Write-Host "=== Dry Run Mode (No actual deletion) ==="
} else {
    Write-Host "=== Delete Log Files ==="
}

$logFiles = @(Get-ChildItem -Path $gameDir -Filter "*.log" -File -ErrorAction SilentlyContinue)
$txtLogFiles = @(Get-ChildItem -Path $gameDir -Filter "*_log.txt" -File -ErrorAction SilentlyContinue)

$allLogs = $logFiles + $txtLogFiles

if ($allLogs.Count -eq 0) {
    Write-Host "No log files found"
    exit 0
}

Write-Host "Found $($allLogs.Count) log files:"
foreach ($file in $allLogs) {
    Write-Host "  - $($file.Name)"
}

if ($dryRun) {
    Write-Host ""
    Write-Host "=== Dry Run Complete ==="
    Write-Host "Would delete: $($allLogs.Count) log files"
    exit 0
}

if ($args.Count -eq 0) {
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to delete these $($allLogs.Count) files? (Y/N)"
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-Host "Aborted."
        exit 0
    }
}

foreach ($file in $allLogs) {
    Remove-Item -Path $file.FullName -Force
    Write-Host "Deleted: $($file.Name)"
}

Write-Host ""
Write-Host "=== Done ==="
Write-Host "Total deleted: $($allLogs.Count) log files"
