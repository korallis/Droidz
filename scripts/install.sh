#!/bin/bash
set -e

echo "🤖 Installing Droidz - Spec-Driven Development for Droid CLI..."

# Detect if we're running from repo or curl pipe
if [ -n "$BASH_SOURCE" ] && [ -f "$BASH_SOURCE" ]; then
  # Running directly from repo
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
  echo "📦 Installing from local repo: $PROJECT_ROOT"
else
  # Running from curl pipe - use current directory
  PROJECT_ROOT="$(pwd)"
  echo "📦 Installing from current directory: $PROJECT_ROOT"
fi

# Target directory (where we're installing)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "📂 Target: $TARGET_DIR"
echo ""

# Create target directories
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/workflows"
mkdir -p "$TARGET_DIR/standards"
mkdir -p "$TARGET_DIR/droidz"

# Copy workflows
echo "📋 Copying workflows..."
if [ -d "$PROJECT_ROOT/workflows" ]; then
  cp -r "$PROJECT_ROOT/workflows/"* "$TARGET_DIR/workflows/" 2>/dev/null || true
  echo "✅ Workflows copied (planning, specification, implementation)"
else
  echo "❌ workflows/ not found at $PROJECT_ROOT/workflows"
  exit 1
fi

# Copy standards
echo "📐 Copying standards templates..."
if [ -d "$PROJECT_ROOT/standards" ]; then
  cp -r "$PROJECT_ROOT/standards/"* "$TARGET_DIR/standards/" 2>/dev/null || true
  echo "✅ Standards templates copied (customize these for your project)"
else
  echo "❌ standards/ not found at $PROJECT_ROOT/standards"
  exit 1
fi

# Copy custom droids
echo "🤖 Copying custom droids..."
if [ -d "$PROJECT_ROOT/.claude/agents" ]; then
  cp -r "$PROJECT_ROOT/.claude/agents/"* "$TARGET_DIR/.claude/agents/" 2>/dev/null || true
  echo "✅ Custom droids copied:"
  echo "   - droidz-planner (product planning with Exa)"
  echo "   - droidz-spec-writer (specifications with Ref)"
  echo "   - droidz-implementer (parallel worker)"
  echo "   - droidz-verifier (verification)"
  echo "   - droidz-orchestrator (workflow coordinator)"
else
  echo "❌ .claude/agents/ not found at $PROJECT_ROOT/.claude/agents"
  exit 1
fi

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
  echo "⚠️  config.yml not found (optional)"
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
