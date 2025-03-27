#!/bin/bash
# configure_wsl_conf.sh
#
# This script takes a custom wsl.conf file (provided as an argument) and ensures that
# /etc/wsl.conf is a symbolic link pointing to that file.
#
# It then asks if you want to restart Windows (to apply the changes to WSL).
#
# Usage: ./configure_wsl_conf.sh /path/to/your/custom/wsl.conf
#
# The script creates a backup of an existing /etc/wsl.conf if it is not already a symlink.
set -euo pipefail

# Re-run the script as root if not already.
if [ "$EUID" -ne 0 ]; then
  echo "Not running as root. Re-executing with sudo..."
  exec sudo "$0" "$@"
fi

# Check if a custom wsl.conf file was provided.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/your/custom/wsl.conf"
  exit 1
fi

CUSTOM_WSL_CONF=$(realpath "$1")
if [ ! -f "$CUSTOM_WSL_CONF" ]; then
  echo "Error: The provided file '$CUSTOM_WSL_CONF' does not exist or is not a regular file."
  exit 1
fi

TARGET="/etc/wsl.conf"

echo "Ensuring that $TARGET is a symlink to $CUSTOM_WSL_CONF..."

if [ -e "$TARGET" ]; then
  if [ -L "$TARGET" ]; then
    CURRENT_TARGET=$(readlink -f "$TARGET")
    if [ "$CURRENT_TARGET" = "$CUSTOM_WSL_CONF" ]; then
      echo "$TARGET already symlinks to $CUSTOM_WSL_CONF. No changes needed."
      exit 0
    else
      echo "$TARGET is a symlink to $CURRENT_TARGET. Removing it..."
      rm "$TARGET"
    fi
  else
    echo "$TARGET exists as a regular file. Backing it up to $TARGET.bak..."
    mv "$TARGET" "$TARGET.bak"
  fi
fi

echo "Creating symlink: $TARGET -> $CUSTOM_WSL_CONF"
ln -s "$CUSTOM_WSL_CONF" "$TARGET"
echo "Symlink created successfully."

read -p "WSL configuration updated. Do you want to restart Windows now? (y/N): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Restarting Windows..."
  # Use an explicit path to PowerShell to avoid 'command not found' in WSL.
  POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
  if [ ! -x "$POWERSHELL" ]; then
    echo "Error: Unable to find PowerShell executable at $POWERSHELL"
    exit 1
  fi
  "$POWERSHELL" -NoProfile -Command "Restart-Computer -Force"
else
  echo "Windows restart skipped."
fi
