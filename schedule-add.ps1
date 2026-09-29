$taskName   = "kk-GuelphAddressLayer"
$projectDir = $PSScriptRoot
$logFile    = "$projectDir\logs\scheduler.log"

if (-not (Test-Path "$projectDir\logs")) {
    New-Item -ItemType Directory -Path "$projectDir\logs" | Out-Null
}

# The shared runner sweeps stale git locks, pulls the slug into the vault
# (--wait coalesces onto an in-flight pull; exit 75 = offline, skip quietly),
# then runs `python run.py update`. It is what the Oakville and Toronto tasks
# actually run, so Guelph behaves the same way.
$runner = Join-Path (Split-Path $projectDir -Parent) "pull-then-update.cmd"
if (-not (Test-Path $runner)) { throw "Runner not found: $runner" }

$action = New-ScheduledTaskAction `
    -Execute "cmd.exe" `
    -Argument "/c `"`"$runner`" guelph `"$projectDir`" >> `"$logFile`" 2>&1`""

# Daily at 16:00: after the 12:00 vault refresh, clear of the Toronto (14:00)
# and Oakville (17:00) layer builds. Nothing is ever scheduled between 00:00
# and 06:30.
$trigger  = New-ScheduledTaskTrigger -Daily -At "16:00"
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2) -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force

Write-Host "Scheduled '$taskName' to run daily at 16:00."
Write-Host "Log: $logFile"
