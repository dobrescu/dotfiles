#!/bin/bash
# install_fonts_common.sh
#
# This file contains common functions for installing fonts on Windows
# via WSL. It copies TrueType (.ttf) files from a given source directory
# to the current user's Windows fonts folder and registers them in the
# registry under HKCU with a nice font name (extracted via fc-scan) and
# a full Windows path.
#
# Usage:
#   source ./install_fonts_common.sh
#   install_fonts_from_dir "/path/to/extracted/fonts"
#
# Prerequisites:
#   - WSL Ubuntu with curl, unzip, sed, jq, and basic Unix tools installed.
#   - fontconfig (for fc-scan) installed.
#   - PowerShell available via powershell.exe.
#
set -euo pipefail

install_fonts_from_dir() {
    local source_dir="$1"
    if [ ! -d "$source_dir" ]; then
        echo "Error: Directory $source_dir does not exist."
        return 1
    fi

    # Retrieve the Windows LOCALAPPDATA path via PowerShell.
    LOCALAPPDATA=$(powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('LocalApplicationData')" | tr -d '\r\n')
    if [ -z "$LOCALAPPDATA" ]; then
      echo "Error: Unable to retrieve LOCALAPPDATA path from PowerShell."
      return 1
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

    # Find all TrueType font files in the source directory.
    FONT_FILES=$(find "$source_dir" -type f -iname "*.ttf")
    if [ -z "$FONT_FILES" ]; then
      echo "Error: No TrueType font files found in $source_dir."
      return 1
    fi

    # Copy each .ttf file to the Windows fonts directory.
    for font in $FONT_FILES; do
      basefont=$(basename "$font")
      echo "Copying $basefont to $WIN_FONTS_DIR_LINUX..."
      cp "$font" "$WIN_FONTS_DIR_LINUX/"
    done

    # Register each font in the Windows registry under HKCU.
    for font in $FONT_FILES; do
      basefont=$(basename "$font")
      # Extract the nice, full font name using fc-scan.
      niceFontName=$(fc-scan --format='%{fullname}' "$font" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [ -z "$niceFontName" ]; then
        niceFontName="${basefont%.*}"
      fi
      fontName="${niceFontName} (TrueType)"
      # Construct the full Windows path to the font file.
      FULL_FONT_PATH="${WIN_FONTS_DIR}\\${basefont}"
      # Register the font using New-ItemProperty with -Force (which creates or updates).
      reg_cmd="New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name '$fontName' -Value '$FULL_FONT_PATH' -PropertyType String -Force"
      echo "Registering font '$fontName' with value '$FULL_FONT_PATH'..."
      powershell.exe -NoProfile -Command "$reg_cmd" >/dev/null
    done
}
