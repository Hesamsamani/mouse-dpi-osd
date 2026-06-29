#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Install Mouse DPI OSD: AutoHotkey v2, startup shortcut, logon task, launch now.
#>
$ErrorActionPreference = 'Continue'
$MouseDir = $PSScriptRoot
$Ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
$OsdScript = Join-Path $MouseDir 'Mouse-DPI-OSD.ahk'

function Log($m) { Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $m" }

Log '=== Mouse DPI OSD Install ==='

if (-not (Test-Path $Ahk)) {
    Log 'Installing AutoHotkey v2 via winget...'
    winget install AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements | Out-Null
}
if (-not (Test-Path $Ahk)) {
    Log 'ERROR: Install AutoHotkey v2 from https://www.autohotkey.com/'
    exit 1
}

Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$startup = [Environment]::GetFolderPath('Startup')
$lnkPath = Join-Path $startup 'Mouse DPI OSD.lnk'
$wsh = New-Object -ComObject WScript.Shell
$sc = $wsh.CreateShortcut($lnkPath)
$sc.TargetPath = $Ahk
$sc.Arguments = "`"$OsdScript`""
$sc.WorkingDirectory = $MouseDir
$sc.WindowStyle = 7
$sc.Save()
Log "Startup shortcut: $lnkPath"

$taskName = 'Mouse-DPI-OSD'
$action = New-ScheduledTaskAction -Execute $Ahk -Argument "`"$OsdScript`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Log "Logon task: $taskName"

Start-Process -FilePath $Ahk -ArgumentList "`"$OsdScript`"" -WindowStyle Hidden
Log 'Mouse DPI OSD running. Tray icon -> Test popup. Tray -> Button finder to map DPI key.'