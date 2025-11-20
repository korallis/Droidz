#!/bin/bash
#
# Droid Format Workaround Hook
# Attempts to work around Factory.ai CLI bug looking for .json instead of .md
#
# This hook intercepts Read tool calls and checks if Factory.ai is trying
# to read a .json droid file. If so, it redirects to the .md file.
#
# ⚠️ EXPERIMENTAL - May not work depending on how Factory.ai loads droids
#

set -e

# Read JSON input from stdin
input=$(cat)

# Extract tool info
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only intercept Read tool
if [ "$tool_name" != "Read" ]; then
    exit 0
fi

# Check if trying to read a droid .json file
if [[ "$file_path" == *.factory/droids/*.json ]]; then
    # Extract base name without extension
    base_path="${file_path%.json}"
    md_file="${base_path}.md"
    
    # Check if corresponding .md file exists
    if [ -f "$md_file" ]; then
        # ATTEMPT: Return decision to use .md file instead
        # NOTE: Factory.ai hooks may not support this level of control
        cat <<EOF
{
  "decision": "approve",
  "updatedInput": {
    "file_path": "$md_file"
  },
  "reason": "Redirecting .json droid file to .md format (CLI bug workaround)"
}
EOF
        exit 0
    fi
fi

# Default: allow through
exit 0
