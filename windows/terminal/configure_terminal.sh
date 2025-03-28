#!/bin/bash
# configure_terminal.sh
# This script locates the Windows Terminal Preview settings.json file and deep merges a JSON snippet
# (provided as an argument) into the settings file without creating a backup.
#
# After merging, it updates the "defaultProfile" property dynamically by finding the GUID of the Ubuntu profile
# with "source" equal to "CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc".
#
# Usage: ./configure_terminal.sh /path/to/merge.json
#
# The merge.json should contain the JSON snippet you wish to merge into the settings.
#
# Exit immediately if any command fails.
set -euo pipefail

# Check if a merge file was provided.
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/merge.json"
  exit 1
fi

# Get absolute path for the merge file.
merge_file=$(realpath "$1")

# Ensure the merge file exists.
if [ ! -f "$merge_file" ]; then
  echo "Error: Merge file '$merge_file' not found."
  exit 1
fi

# Validate that the merge file is valid JSON.
if ! jq empty "$merge_file" >/dev/null 2>&1; then
  echo "Error: Merge file '$merge_file' is not valid JSON."
  exit 1
fi

# Retrieve the Windows username via cmd.exe from a local directory to avoid UNC path issues.
win_username=$(cd /tmp && cmd.exe /C "echo %USERNAME%" | tr -d '\r\n')
if [ -z "$win_username" ]; then
  echo "Error: Unable to determine Windows username."
  exit 1
fi

# Path to the Windows Terminal Preview settings.json file.
settings_path="/mnt/c/Users/${win_username}/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json"
if [ ! -f "$settings_path" ]; then
  echo "Error: Windows Terminal Preview settings.json not found at:"
  echo "       $settings_path"
  exit 1
fi

# Define the jq filter for recursive deep merging with safe handling of non-object values.
jq_filter="
  def keys_or_empty:
    if type == \"object\" then keys_unsorted else [] end;
  def rmerge(a; b):
    if (a | type) == \"object\" and (b | type) == \"object\" then
      a as \$a | b as \$b |
      reduce ((\$a | keys_or_empty) + (\$b | keys_or_empty) | unique)[] as \$k
        ( {}; .[\$k] = (if (\$a[\$k] != null and \$b[\$k] != null) then rmerge(\$a[\$k]; \$b[\$k]) else (\$b[\$k] // \$a[\$k]) end) )
    else
      b // a
    end;
  .[0] as \$orig | .[1] as \$merge | rmerge(\$orig; \$merge)
"

# Merge the original settings and the merge JSON.
if jq -s "$jq_filter" "$settings_path" "$merge_file" > "${settings_path}.tmp"; then
  mv "${settings_path}.tmp" "$settings_path"
  echo "Settings successfully merged into Windows Terminal Preview settings.json."
else
  echo "Error: Failed to merge settings."
  rm -f "${settings_path}.tmp"
  exit 1
fi

# Dynamically update the "defaultProfile" property based on the Ubuntu profile GUID.
desired_guid=$(jq -r '.profiles.list[] | select(.source == "CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc") | .guid' "$settings_path")
if [ -z "$desired_guid" ] || [ "$desired_guid" = "null" ]; then
  echo "Error: Unable to find the Ubuntu profile GUID in the profiles list."
  exit 1
fi

echo "Found Ubuntu profile GUID: $desired_guid"
echo "Updating defaultProfile to the discovered GUID..."
if jq --arg guid "$desired_guid" '.defaultProfile = $guid' "$settings_path" > "${settings_path}.tmp"; then
  mv "${settings_path}.tmp" "$settings_path"
  echo "defaultProfile updated dynamically to $desired_guid"
else
  echo "Error: Failed to update defaultProfile."
  rm -f "${settings_path}.tmp"
  exit 1
fi

echo "Script completed successfully."
