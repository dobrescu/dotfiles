#!/bin/bash
# install_vscode_insiders_remote.sh
#
# Installs VS Code Insiders on Windows via winget and optionally symlinks settings.json.
#
# Usage:
#   ./install_vscode_insiders_remote.sh [custom_settings.json]
#

set -euo pipefail

echo "Checking for winget availability..."
if ! powershell.exe -NoProfile -Command "winget --version" >/dev/null 2>&1; then
  echo "Error: winget is not available on your system."
  exit 1
fi

echo "Installing Visual Studio Code Insiders via winget..."
if ! powershell.exe -NoProfile -Command "winget install --name 'Visual Studio Code - Insiders' -e --source msstore --accept-package-agreements --accept-source-agreements"; then
  echo "VS Code Insiders is already installed or no newer version is available. Continuing..."
fi

echo "Waiting for Visual Studio Code Insiders installation..."
while true; do
  output=$(powershell.exe -NoProfile -Command "winget list --source msstore --name 'Visual Studio Code - Insiders' | Out-String")
  if echo "$output" | grep -qi "Microsoft Visual Studio Code Insiders"; then
    echo "Visual Studio Code Insiders installation detected."
    break
  else
    echo "VS Code Insiders not yet detected. Waiting 5 seconds..."
    sleep 5
  fi
done

# Retrieve Windows username
win_username=$(cmd.exe /C "echo %USERNAME%" | tr -d '\r\n')
if [ -z "$win_username" ]; then
  echo "Error: Unable to determine Windows username."
  exit 1
fi

# Determine the VS Code Insiders executable
if command -v code-insiders >/dev/null 2>&1; then
  CODE_CMD="code-insiders"
else
  FALLBACK_CODE="/mnt/c/Users/${win_username}/AppData/Local/Programs/Microsoft VS Code Insiders/Code - Insiders.exe"
  if [ -f "$FALLBACK_CODE" ]; then
    CODE_CMD="$FALLBACK_CODE"
  else
    echo "Error: Unable to locate the VS Code Insiders executable."
    exit 1
  fi
fi

echo "Using VS Code Insiders command: $CODE_CMD"

# Optional: Configure WSL VS Code Insiders settings if a file is provided
if [ "$#" -ge 1 ]; then
  CUSTOM_SETTINGS_FILE=$(realpath "$1")
  if [ ! -f "$CUSTOM_SETTINGS_FILE" ]; then
    echo "Error: Custom settings file '$CUSTOM_SETTINGS_FILE' does not exist."
    exit 1
  fi

  # Define the VS Code settings.json path inside WSL (for Remote - WSL)
  WSL_VSCODE_SETTINGS="$HOME/.vscode-server-insiders/data/Machine/settings.json"

  # Ensure the directory exists before proceeding
  SETTINGS_DIR=$(dirname "$WSL_VSCODE_SETTINGS")
  if [ ! -d "$SETTINGS_DIR" ]; then
    echo "Creating settings directory: $SETTINGS_DIR"
    mkdir -p "$SETTINGS_DIR"
  fi

  # Handle existing settings file
  if [ -e "$WSL_VSCODE_SETTINGS" ]; then
    if [ -L "$WSL_VSCODE_SETTINGS" ]; then
      # Check if the symlink already points to the correct file
      EXISTING_TARGET=$(readlink -f "$WSL_VSCODE_SETTINGS")
      if [ "$EXISTING_TARGET" = "$CUSTOM_SETTINGS_FILE" ]; then
        echo "✅ Symlink already exists and points to the correct file. No action needed."
        exit 0
      else
        echo "🔄 Existing symlink points to '$EXISTING_TARGET'. Removing and recreating..."
        rm -f "$WSL_VSCODE_SETTINGS"
      fi
    elif [ -f "$WSL_VSCODE_SETTINGS" ]; then
      echo "📂 Backing up existing settings file to '$WSL_VSCODE_SETTINGS.bak'..."
      mv "$WSL_VSCODE_SETTINGS" "$WSL_VSCODE_SETTINGS.bak"
    elif [ -d "$WSL_VSCODE_SETTINGS" ]; then
      echo "🗑 Removing existing directory '$WSL_VSCODE_SETTINGS'..."
      rm -rf "$WSL_VSCODE_SETTINGS"
    fi
  fi

  # Create the symlink
  echo "🔗 Creating symlink: $WSL_VSCODE_SETTINGS → $CUSTOM_SETTINGS_FILE"
  ln -s "$CUSTOM_SETTINGS_FILE" "$WSL_VSCODE_SETTINGS"

  # Verify if the symlink was created successfully
  if [ $? -eq 0 ]; then
    echo "✅ WSL VS Code settings successfully symlinked to '$CUSTOM_SETTINGS_FILE'."
  else
    echo "❌ Error: Symlink creation failed."
    exit 1
  fi
fi

echo "🎉 Script completed successfully."
