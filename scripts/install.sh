#!/bin/bash
set -e

echo "🤖 Installing Droidz - Spec-Driven Development for Droid CLI..."

# Configuration
REPO="${DROIDZ_REPO:-korallis/Droidz}"
BRANCH="${DROIDZ_BRANCH:-main}"
TARGET_DIR="${1:-.}"

# Detect if we're running from repo or curl pipe
if [ -n "$BASH_SOURCE" ] && [ -f "$BASH_SOURCE" ]; then
  # Running directly from cloned repo
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
  CLEANUP_TEMP=false
  echo "📦 Installing from local repo: $PROJECT_ROOT"
else
  # Running from curl pipe - download from GitHub
  echo "📦 Downloading from GitHub: $REPO @ $BRANCH"
  
  TAR_URL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}"
  TMP_DIR="$(mktemp -d)"
  CLEANUP_TEMP=true
  
  echo "⬇️  Downloading..."
  if ! curl -fsSL "$TAR_URL" -o "$TMP_DIR/repo.tar.gz"; then
    echo "❌ Failed to download from GitHub"
    rm -rf "$TMP_DIR"
    exit 1
  fi
  
  echo "📦 Extracting..."
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
  
  # Find the extracted directory (GitHub creates folder named repo-branch)
  PROJECT_ROOT="$(find "$TMP_DIR" -maxdepth 1 -type d -name "${REPO##*/}-*" | head -n 1)"
  
  if [ -z "$PROJECT_ROOT" ] || [ ! -d "$PROJECT_ROOT" ]; then
    echo "❌ Could not find extracted directory"
    rm -rf "$TMP_DIR"
    exit 1
  fi
  
  echo "✅ Downloaded to: $PROJECT_ROOT"
fi

# Resolve target directory to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || pwd)"
echo "📂 Target: $TARGET_DIR"
echo ""

# Verify source directories exist
for dir in workflows standards .claude/agents; do
  if [ ! -d "$PROJECT_ROOT/$dir" ]; then
    echo "❌ Required directory not found: $dir"
    [ "$CLEANUP_TEMP" = true ] && rm -rf "$TMP_DIR"
    exit 1
  fi
done

# Create target directories
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/workflows"
mkdir -p "$TARGET_DIR/standards"
mkdir -p "$TARGET_DIR/droidz"

# Copy workflows
echo "📋 Copying workflows..."
if ! cp -r "$PROJECT_ROOT/workflows/"* "$TARGET_DIR/workflows/" 2>/dev/null; then
  echo "❌ Failed to copy workflows"
  [ "$CLEANUP_TEMP" = true ] && rm -rf "$TMP_DIR"
  exit 1
fi
echo "✅ Workflows copied (planning, specification, implementation)"

# Copy standards
echo "📐 Copying standards templates..."
if ! cp -r "$PROJECT_ROOT/standards/"* "$TARGET_DIR/standards/" 2>/dev/null; then
  echo "❌ Failed to copy standards"
  [ "$CLEANUP_TEMP" = true ] && rm -rf "$TMP_DIR"
  exit 1
fi
echo "✅ Standards templates copied (customize these for your project)"

# Copy custom droids
echo "🤖 Copying custom droids..."
if ! cp -r "$PROJECT_ROOT/.claude/agents/"* "$TARGET_DIR/.claude/agents/" 2>/dev/null; then
  echo "❌ Failed to copy droids"
  [ "$CLEANUP_TEMP" = true ] && rm -rf "$TMP_DIR"
  exit 1
fi
echo "✅ Custom droids copied:"
echo "   - droidz-planner (product planning with Exa)"
echo "   - droidz-spec-writer (specifications with Ref)"
echo "   - droidz-implementer (parallel worker)"
echo "   - droidz-verifier (verification)"
echo "   - droidz-orchestrator (workflow coordinator)"

# Copy config
echo "⚙️  Copying configuration..."
if [ -f "$PROJECT_ROOT/config.yml" ]; then
  if [ ! -f "$TARGET_DIR/config.yml" ]; then
    cp "$PROJECT_ROOT/config.yml" "$TARGET_DIR/config.yml"
    echo "✅ Configuration copied"
  else
    echo "⚠️  config.yml already exists, skipping (won't overwrite)"
  fi
else
  echo "⚠️  config.yml not found in source"
fi

# Cleanup temp directory if we downloaded
if [ "$CLEANUP_TEMP" = true ]; then
  rm -rf "$TMP_DIR"
  echo "🧹 Cleaned up temporary files"
fi

echo ""
echo "✅ Droidz installation complete!"
echo ""
echo "📚 What You Got:"
echo "   • workflows/ - Planning, specification, and parallel implementation workflows"
echo "   • standards/ - Coding, architecture, and security standards (customize these!)"
echo "   • .claude/agents/ - 5 specialized droids for the workflow"
echo "   • config.yml - Parallel execution and research settings"
echo ""
echo "🚀 Quick Start:"
echo "1. Open Droid CLI: droid"
echo "2. Start with: @droidz-orchestrator"
echo "3. Choose NEW product or EXISTING roadmap"
echo "4. Let Droidz plan, spec, and implement with parallel execution"
echo ""
echo "📖 Documentation:"
echo "   • README.md - Complete guide"
echo "   • workflows/ - See how each phase works"
echo "   • standards/ - Customize for your project"
echo ""
