#!/bin/bash
# Run quick validation on edited files
# Hook: PostToolUse (Edit|Create tools)

set -euo pipefail

# Get the file that was edited (passed as argument)
FILE="${1:-}"

if [ -z "$FILE" ]; then
  exit 0  # No file to validate
fi

if [ ! -f "$FILE" ]; then
  exit 0  # File doesn't exist (maybe deleted)
fi

echo "🔍 Quick validation: $FILE"

# Get file extension
EXT="${FILE##*.}"

# Run quick checks based on file type
case "$EXT" in
  ts|tsx|js|jsx)
    # TypeScript/JavaScript: Quick syntax check
    if command -v tsc &> /dev/null && [[ "$EXT" =~ ^ts ]]; then
      echo "  ✓ TypeScript syntax check..."
      tsc --noEmit "$FILE" 2>&1 | head -5 || true
    fi
    
    # ESLint if available
    if command -v eslint &> /dev/null; then
      echo "  ✓ ESLint check..."
      eslint "$FILE" 2>&1 | head -10 || true
    fi
    ;;
    
  py)
    # Python: Quick syntax check
    if command -v python3 &> /dev/null; then
      echo "  ✓ Python syntax check..."
      python3 -m py_compile "$FILE" 2>&1 || true
    fi
    
    # Ruff if available
    if command -v ruff &> /dev/null; then
      echo "  ✓ Ruff check..."
      ruff check "$FILE" 2>&1 | head -10 || true
    fi
    ;;
    
  go)
    # Go: Quick syntax check
    if command -v go &> /dev/null; then
      echo "  ✓ Go syntax check..."
      go vet "$FILE" 2>&1 || true
    fi
    ;;
    
  rs)
    # Rust: Quick syntax check
    if command -v rustc &> /dev/null; then
      echo "  ✓ Rust syntax check..."
      rustc --parse "$FILE" 2>&1 || true
    fi
    ;;
    
  *)
    # No specific validation for this file type
    echo "  ℹ️  No quick validation for .$EXT files"
    ;;
esac

echo "✅ Quick validation complete"

# Always exit 0 (don't block on validation failures)
exit 0
