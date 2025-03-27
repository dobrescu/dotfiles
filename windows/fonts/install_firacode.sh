#!/bin/bash
# install_fira_code.sh
#
# This script downloads the latest Fira Code font zip file from the official
# tonsky/FiraCode GitHub release (dynamically determined), extracts the TrueType font files,
# copies them to the current user's Windows fonts directory, and registers the fonts
# in the Windows registry under HKCU.
#
# Prerequisites:
#   - WSL Ubuntu with curl, unzip, sed, jq, and basic Unix tools installed.
#   - PowerShell available via powershell.exe.
#
# Usage: ./install_fira_code.sh
#
# Note: This installs fonts per-user. For system-wide installation (in C:\Windows\Fonts),
#       administrative privileges are required.
set -euo pipefail

# Retrieve latest release info from the FiraCode GitHub API.
release_info=$(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest)
if [ -z "$release_info" ]; then
  echo "Error: Unable to fetch release information from GitHub."
  exit 1
fi

# Extract the browser download URL for the Fira Code zip file using jq.
# The regex matches asset names like "Fira_Code_v6.2.zip" or "FiraCode-v6.2.zip" (case insensitive).
FONT_URL=$(echo "$release_info" | jq -r '.assets[] | select(.name | test("(?i)Fira[_-]?Code.*\\.zip$")) | .browser_download_url')
if [ -z "$FONT_URL" ] || [ "$FONT_URL" == "null" ]; then
  echo "Error: Fira Code zip asset not found in the latest release."
  exit 1
fi

echo "Latest Fira Code URL: $FONT_URL"

# Create a temporary working directory.
TMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TMP_DIR"

# Download the zip file.
ZIP_FILE="$TMP_DIR/FiraCode.zip"
echo "Downloading Fira Code from $FONT_URL..."
curl -L -o "$ZIP_FILE" "$FONT_URL"

# Extract the zip file.
echo "Extracting font files..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR/firacode"

# Retrieve the Windows LOCALAPPDATA path via PowerShell.
LOCALAPPDATA=$(powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('LocalApplicationData')" | tr -d '\r\n')
if [ -z "$LOCALAPPDATA" ]; then
  echo "Error: Unable to retrieve LOCALAPPDATA path from PowerShell."
  exit 1
fi

# Construct the Windows fonts directory path for the current user.
WIN_FONTS_DIR="${LOCALAPPDATA}\\Microsoft\\Windows\\Fonts"
echo "Windows user fonts directory: $WIN_FONTS_DIR"

# Convert the Windows fonts directory to a Linux-accessible path.
WIN_FONTS_DIR_LINUX=$(echo "$WIN_FONTS_DIR" | sed -E 's/^([A-Z]):/\/mnt\/\L\1/' | sed 's/\\/\//g')
echo "Linux path to Windows fonts directory: $WIN_FONTS_DIR_LINUX"

# Create the fonts directory if it doesn't exist.
if [ ! -d "$WIN_FONTS_DIR_LINUX" ]; then
  echo "Creating Windows fonts directory at $WIN_FONTS_DIR_LINUX..."
  mkdir -p "$WIN_FONTS_DIR_LINUX"
fi

# Find all TrueType font files in the extracted directory.
FONT_FILES=$(find "$TMP_DIR/firacode" -type f -iname "*.ttf")
if [ -z "$FONT_FILES" ]; then
  echo "Error: No TrueType font files found in the extracted archive."
  exit 1
fi

# Copy each .ttf file to the Windows fonts directory.
for font in $FONT_FILES; do
  basefont=$(basename "$font")
  echo "Copying $basefont to $WIN_FONTS_DIR_LINUX..."
  cp "$font" "$WIN_FONTS_DIR_LINUX/"
done

# Register the fonts in the Windows registry under HKCU.
# Each font is registered under "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts".
for font in $FONT_FILES; do
  basefont=$(basename "$font")
  # Construct the registry entry name, typically "<Font Name> (TrueType)".
  fontName="${basefont%.*} (TrueType)"
  reg_cmd="New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name '$fontName' -Value '$basefont' -PropertyType String -Force"
  echo "Registering font $fontName..."
  powershell.exe -NoProfile -Command "$reg_cmd" >/dev/null
done

echo "Fira Code installation completed."

# Clean up temporary directory.
rm -rf "$TMP_DIR"
