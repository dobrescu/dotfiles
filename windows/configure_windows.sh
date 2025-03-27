#!/bin/bash
# configure_windows.sh
#
# This script attempts to enable Developer Mode and disable UNC path checks in Windows.
# It uses PowerShell's Start-Process with the -Verb RunAs flag to launch an elevated
# PowerShell instance that runs both registry modifications in a single execution.
#
# Usage: ./configure_windows.sh
#
# Exit immediately if any command fails.
set -euo pipefail

# Change directory to a local Windows path to avoid UNC path issues.
cd /mnt/c/Windows/Temp || { echo "Error: Unable to change directory to /mnt/c/Windows/Temp."; exit 1; }

echo "Attempting to enable Developer Mode and disable UNC check via an elevated registry update..."
# Run both registry modifications inside a single elevated PowerShell instance.
powershell.exe -NoProfile -Command "
Start-Process powershell -ArgumentList '
    reg add \"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1;
    reg add \"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor\" /t REG_DWORD /f /v DisableUNCCheck /d 1
' -Verb RunAs -Wait"

echo "If you accepted the UAC prompt, the registry keys were added. Developer Mode should now be enabled, and UNC path restrictions are disabled."
