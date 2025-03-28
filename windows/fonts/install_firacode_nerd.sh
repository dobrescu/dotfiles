#!/bin/bash
# install_fira_code_nerd_font.sh
#
# This script downloads the latest Fira Code Nerd Font zip file from the official
# Nerd Fonts GitHub release (dynamically determined), extracts the TrueType font files,
# and installs the fonts using the common function defined in install_fonts_common.sh.
#
# Prerequisites:
#   - WSL Ubuntu with curl, unzip, sed, jq, and basic Unix tools installed.
#   - fontconfig (for fc-scan) installed.
#   - PowerShell available via powershell.exe.
#
# Usage: ./install_fira_code_nerd_font.sh
#
# Note: This installs fonts per-user. For system-wide installation (in C:\Windows\Fonts),
#       administrative privileges are required.
set -euo pipefail

# Retrieve latest release info from the Nerd Fonts GitHub API.
release_info=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest)
if [ -z "$release_info" ]; then
  echo "Error: Unable to fetch release information from GitHub."
  exit 1
fi

# Extract the browser download URL for FiraCode.zip using jq.
FONT_URL=$(echo "$release_info" | jq -r '.assets[] | select(.name=="FiraCode.zip") | .browser_download_url')
if [ -z "$FONT_URL" ] || [ "$FONT_URL" == "null" ]; then
  echo "Error: FiraCode.zip not found in the latest release assets."
  exit 1
fi

echo "Latest Fira Code Nerd Font URL: $FONT_URL"

# Create a temporary working directory.
TMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TMP_DIR"

# Download the zip file.
ZIP_FILE="$TMP_DIR/FiraCode.zip"
echo "Downloading Fira Code Nerd Font from $FONT_URL..."
curl -L -o "$ZIP_FILE" "$FONT_URL"

# Extract the zip file.
echo "Extracting font files..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR/firacode"

# Source the common functions file.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=./install_fonts_common.sh
source "$SCRIPT_DIR/install_fonts_common.sh"

# Install the fonts using the common function.
install_fonts_from_dir "$TMP_DIR/firacode"

echo "Fira Code Nerd Font installation completed."

# Clean up temporary directory.
rm -rf "$TMP_DIR"
