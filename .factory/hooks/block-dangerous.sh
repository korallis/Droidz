#!/bin/bash
# Block dangerous commands before execution
# Hook: PreToolUse (Execute tool)

set -euo pipefail

# Get the command being executed (passed as argument)
COMMAND="${1:-}"

if [ -z "$COMMAND" ]; then
  exit 0  # No command to check
fi

# List of dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "rm -rf \*"
  "rm -rf ."
  "dd if="
  "mkfs"
  "fdisk"
  "parted"
  ":(){:|:&};:"  # Fork bomb
  "chmod -R 777 /"
  "chown -R"
  "> /dev/sda"
  "mv ~ /dev/null"
  "wget.*| sh"
  "curl.*| bash"
  "curl.*| sh"
)

# Check if command matches any dangerous pattern
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "❌ BLOCKED: Dangerous command detected!"
    echo "Pattern: $pattern"
    echo "Command: $COMMAND"
    echo ""
    echo "This command could cause irreversible damage."
    echo "If you really need to run this, disable the block-dangerous hook."
    exit 1
  fi
done

# Check for rm -rf with short paths (likely dangerous)
if echo "$COMMAND" | grep -qE "rm\s+-rf\s+[/~]"; then
  echo "⚠️  WARNING: rm -rf with root-like path detected!"
  echo "Command: $COMMAND"
  echo ""
  echo "This looks dangerous. Double-check the path."
  # Don't exit - just warn
fi

# Allow command to proceed
exit 0
