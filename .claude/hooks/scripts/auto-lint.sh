#!/bin/bash
# Auto-lint hook - runs after file edits
# Automatically formats and lints changed files

set -e

# Get the file path from tool input
file_path=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

# Exit if no file path
if [ -z "$file_path" ]; then
  exit 0
fi

# Only process certain file types
if [[ ! "$file_path" =~ \.(ts|tsx|js|jsx|py|rs|go)$ ]]; then
  exit 0
fi

# Change to project root
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo "🔧 Auto-linting: $file_path"

# JavaScript/TypeScript
if [[ "$file_path" =~ \.(ts|tsx|js|jsx)$ ]]; then
  # Check if Prettier exists
  if command -v prettier &> /dev/null || [ -f "node_modules/.bin/prettier" ]; then
    echo "  ✓ Running Prettier..."
    npx prettier --write "$file_path" 2>/dev/null || true
  fi
  
  # Check if ESLint exists
  if command -v eslint &> /dev/null || [ -f "node_modules/.bin/eslint" ]; then
    echo "  ✓ Running ESLint..."
    npx eslint --fix "$file_path" 2>/dev/null || true
  fi
  
  # Check if Biome exists
  if command -v biome &> /dev/null || [ -f "node_modules/.bin/biome" ]; then
    echo "  ✓ Running Biome..."
    npx biome check --apply "$file_path" 2>/dev/null || true
  fi
fi

# Python
if [[ "$file_path" =~ \.py$ ]]; then
  # Check if Black exists
  if command -v black &> /dev/null; then
    echo "  ✓ Running Black..."
    black "$file_path" 2>/dev/null || true
  fi
  
  # Check if isort exists
  if command -v isort &> /dev/null; then
    echo "  ✓ Running isort..."
    isort "$file_path" 2>/dev/null || true
  fi
fi

# Rust
if [[ "$file_path" =~ \.rs$ ]]; then
  if command -v rustfmt &> /dev/null; then
    echo "  ✓ Running rustfmt..."
    rustfmt "$file_path" 2>/dev/null || true
  fi
fi

# Go
if [[ "$file_path" =~ \.go$ ]]; then
  if command -v gofmt &> /dev/null; then
    echo "  ✓ Running gofmt..."
    gofmt -w "$file_path" 2>/dev/null || true
  fi
fi

echo "✅ Linting complete"
exit 0
