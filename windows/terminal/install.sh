#!/bin/bash
# install_windows_terminal_preview.sh
#
# This script installs the Windows Terminal Preview app in Windows using winget,
# invoked via PowerShell from WSL.
#
# It first updates winget’s sources, then installs Windows Terminal Preview via winget
# using the package name ("Windows Terminal Preview") from the msstore source, and finally
# polls until the installation is detected (via winget list).
#
# Optionally, if an argument is provided (the full path to a custom LocalState directory),
# the script will remove the existing Windows Terminal Preview LocalState directory (if it exists)
# and create a symbolic link to your custom LocalState directory.
#
# Prerequisites:
#   - Windows 10/11 with winget installed.
#   - WSL Ubuntu with PowerShell accessible via powershell.exe.
#
# Usage:
#   ./install_windows_terminal_preview.sh [custom_localstate_directory]
#
# Exit immediately if any command fails.
set -euo pipefail

echo "Updating winget sources..."
powershell.exe -NoProfile -Command "winget source update" >/dev/null

echo "Checking for winget availability..."
if ! powershell.exe -NoProfile -Command "winget --version" >/dev/null 2>&1; then
  echo "Error: winget is not available on your system."
  echo "Please install winget from the Microsoft Store or via the App Installer and try again."
  exit 1
fi

echo "Installing Windows Terminal Preview via winget from msstore..."
install_output=$(powershell.exe -NoProfile -Command "winget install --name 'Windows Terminal Preview' -e --source msstore --accept-package-agreements --accept-source-agreements" 2>&1 || true)
echo "$install_output"
# If the output indicates the package is already installed (or no upgrade available), continue.
if echo "$install_output" | grep -qi "Error:" && ! echo "$install_output" | grep -qi "No available upgrade found"; then
  echo "Error: Windows Terminal Preview package not found or another error occurred. Please verify its availability."
  exit 1
else
  echo "Windows Terminal Preview is already installed or the installation command completed successfully."
fi

echo "Waiting for Windows Terminal Preview to be fully installed..."
while true; do
  output=$(powershell.exe -NoProfile -Command "winget list --name 'Windows Terminal Preview' --source msstore | Out-String")
  if echo "$output" | grep -qi "Windows Terminal Preview"; then
    echo "Windows Terminal Preview installation detected."
    break
  else
    echo "Windows Terminal Preview not yet detected. Waiting 5 seconds..."
    sleep 5
  fi
done

echo "Windows Terminal Preview is fully installed."
echo "Launching Windows Terminal Preview in background..."
powershell.exe -NoProfile -Command "Start-Process explorer.exe -ArgumentList 'shell:AppsFolder\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe!App'" >/dev/null 2>&1
echo "Windows Terminal Preview launched."