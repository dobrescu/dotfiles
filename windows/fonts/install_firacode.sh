#!/bin/bash
# install_fira_code.sh
#
# This script downloads the latest Fira Code font zip file from the official
# tonsky/FiraCode GitHub release (dynamically determined), extracts the TrueType font files,
# and installs the fonts using the common installation function defined in install_fonts_common.sh.
#
# Prerequisites:
#   - WSL Ubuntu with curl, unzip, sed, jq, and basic Unix tools installed.
#   - fontconfig (for fc-scan) installed.
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

# Source the common functions file and install the fonts.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/install_fonts_common.sh"
install_fonts_from_dir "$TMP_DIR/firacode"

echo "Fira Code installation completed."

# Clean up temporary directory.
rm -rf "$TMP_DIR"
