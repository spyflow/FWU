<#!
Script Name: F*ck You Windows Update
Author: spyflow
GitHub: https://github.com/spyflow
Portfolio: https://portafolio.spyflow.tech

Description:
Pauses Windows Updates for a custom duration (like the Settings > Pause button)
with multiple methods to ensure execution, including auto-elevation to run as Administrator.
Run this file directly; if not elevated, it will restart itself with admin rights.
#>

# --- Auto-elevate if not running as Administrator ---
function Ensure-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Restarting script with Administrator rights..."
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $psi.Verb = "runas"
        try {
            [Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            Write-Error "User cancelled elevation. Exiting."
        }
        exit
    }
}

Ensure-Admin

$ErrorActionPreference = 'Stop'

function To-FileTime($dt) {
    return $dt.ToFileTimeUtc()
}

function Pause-WindowsUpdate($days) {
    $WUKey = "HKLM:\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings"
    if (-not (Test-Path $WUKey)) { New-Item -Path $WUKey -Force | Out-Null }

    $start = [DateTime]::UtcNow
    $expiry = $start.AddDays($days)

    # Registry method (same as pause button)
    Set-ItemProperty -Path $WUKey -Name PauseUpdatesStartTime  -Value (To-FileTime $start)  -Type QWord
    Set-ItemProperty -Path $WUKey -Name PauseUpdatesExpiryTime -Value (To-FileTime $expiry) -Type QWord

    Write-Host "Windows Update paused for $days days (until $expiry)" -ForegroundColor Green
}

function Resume-WindowsUpdate {
    $WUKey = "HKLM:\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings"

    try { Remove-ItemProperty -Path $WUKey -Name PauseUpdatesStartTime, PauseUpdatesExpiryTime -ErrorAction SilentlyContinue } catch {}

    Write-Host "Windows Update resumed." -ForegroundColor Yellow
}

# --- Menu ---
function Show-Menu {
    Clear-Host
    Write-Host "==============================="
    Write-Host " F*ck You Windows Update"
    Write-Host "==============================="
    Write-Host "1) Pause 1 week"
    Write-Host "2) Pause 1 month"
    Write-Host "3) Pause 3 months"
    Write-Host "4) Pause 6 months"
    Write-Host "5) Pause 1 year"
    Write-Host "6) Pause custom (days)"
    Write-Host "7) Resume updates"
    Write-Host "0) Exit"
    Write-Host "==============================="
}

Do {
    Show-Menu
    $choice = Read-Host "Select an option"
    switch ($choice) {
        '1' { Pause-WindowsUpdate -days 7 }
        '2' { Pause-WindowsUpdate -days 30 }
        '3' { Pause-WindowsUpdate -days 90 }
        '4' { Pause-WindowsUpdate -days 180 }
        '5' { Pause-WindowsUpdate -days 365 }
        '6' {
            $customDays = Read-Host "Enter number of days to pause"
            if ($customDays -match '^[0-9]+$' -and [int]$customDays -gt 0) {
                Pause-WindowsUpdate -days ([int]$customDays)
            } else {
                Write-Host "Invalid number." -ForegroundColor Red
            }
        }
        '7' { Resume-WindowsUpdate }
        '0' { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid option. Try again." -ForegroundColor Red }
    }
    if ($choice -ne '0') { Pause }
} While ($choice -ne '0')

