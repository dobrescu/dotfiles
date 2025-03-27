#!/bin/bash
# install_vscode_extensions.sh
#
# This script installs a list of Visual Studio Code extensions in two categories:
# 1. Windows-based extensions (installed via PowerShell)
# 2. WSL-based extensions (installed via 'code-insiders' inside WSL)
#
# Usage: ./install_extensions.sh
#

set -euo pipefail

# Ensure VS Code CLI is available in WSL
if ! command -v code-insiders &>/dev/null; then
  echo "Error: 'code-insiders' command not found. Please start VS Code Insiders from WSL at least once."
  exit 1
fi

# Define Windows extensions (installed using PowerShell)
WINDOWS_EXTENSIONS=(
  "ms-vscode-remote.remote-wsl"  # Required for WSL remote development
)

# Define WSL extensions (installed inside WSL)
WSL_EXTENSIONS=(
  "dbaeumer.vscode-eslint"       # ESLint
  "esbenp.prettier-vscode"       # Prettier for formatting
  "timonwong.shellcheck"         # ShellCheck for shell script linting
  "foxundermoon.shell-format"    # Shell format
)

# Function to install extensions in Windows
install_windows_extensions() {
  echo "Installing VS Code extensions in Windows..."
  for EXT in "${WINDOWS_EXTENSIONS[@]}"; do
    echo "Installing $EXT on Windows..."
    powershell.exe -NoProfile -Command "code-insiders --install-extension $EXT" || echo "Failed to install $EXT on Windows"
  done
}

# Function to install extensions in WSL
install_wsl_extensions() {
  echo "Installing VS Code extensions in WSL..."
  for EXT in "${WSL_EXTENSIONS[@]}"; do
    echo "Installing $EXT in WSL..."
    code-insiders --install-extension "$EXT" || echo "Failed to install $EXT in WSL"
  done
}

# Install Windows extensions
install_windows_extensions

# Install WSL extensions
install_wsl_extensions

echo "✅ VS Code extensions installed successfully."
