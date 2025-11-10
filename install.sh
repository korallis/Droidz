#!/bin/bash
set -e

# Droidz Installer
# Installs or updates Droidz in your project
# Updated: 2025-01-10 - Simplified MCP setup

DROIDZ_VERSION="2.1.0"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/main"
CACHE_BUST="?v=${DROIDZ_VERSION}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    log_error "Not in a git repository. Please run this from your project root."
    exit 1
fi

# Detect if this is an install or update
if [ -d ".factory/droids" ] && [ -f "orchestrator/task-coordinator.ts" ]; then
    MODE="update"
    log_info "Existing Droidz installation detected. Updating..."
else
    MODE="install"
    log_info "Installing Droidz v${DROIDZ_VERSION}..."
fi

echo ""

# Create directories
log_info "Creating directories..."
mkdir -p .factory/droids
mkdir -p .factory/commands
mkdir -p orchestrator
log_success "Directories created"

# Download droids
log_info "Downloading robot helpers (droids)..."

DROIDS=(
    "droidz-orchestrator.md"
    "codegen.md"
    "test.md"
    "refactor.md"
    "infra.md"
    "integration.md"
    "generalist.md"
)

for droid in "${DROIDS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/droids/${droid}${CACHE_BUST}" -o ".factory/droids/${droid}"
    log_success "Downloaded ${droid}"
done

# Download custom commands
log_info "Downloading custom slash commands..."

COMMANDS=(
    "droidz-orchestrator.md"
    "droidz-codegen.md"
    "droidz-generalist.md"
    "droidz-infra.md"
    "droidz-integration.md"
    "droidz-refactor.md"
    "droidz-test.md"
    "setup-linear-project.md"
)

for command in "${COMMANDS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/commands/${command}${CACHE_BUST}" -o ".factory/commands/${command}"
    log_success "Downloaded ${command}"
done

# Download orchestrator scripts
log_info "Downloading orchestrator scripts..."

SCRIPTS=(
    "worktree-setup.ts"
    "task-coordinator.ts"
    "types.ts"
    "config.json"
)

for script in "${SCRIPTS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/orchestrator/${script}${CACHE_BUST}" -o "orchestrator/${script}"
    log_success "Downloaded ${script}"
done

# Download config.example.yml template
log_info "Downloading configuration template..."
curl -fsSL "${GITHUB_RAW}/config.example.yml${CACHE_BUST}" -o "config.example.yml"
log_success "Downloaded config.example.yml"

# Handle config.yml
if [ -f "config.yml" ]; then
    log_warning "config.yml already exists - preserving your existing configuration"
    log_info "Compare with config.example.yml to see new simplified settings"
else
    cp config.example.yml config.yml
    log_success "Created config.yml from template"
    log_info "Simple config - just set your Linear project name (optional)"
fi

# Download documentation
log_info "Downloading documentation..."
curl -fsSL "${GITHUB_RAW}/README.md${CACHE_BUST}" -o "README.md"
log_success "Downloaded README.md"
curl -fsSL "${GITHUB_RAW}/CHANGELOG.md${CACHE_BUST}" -o "CHANGELOG.md"
log_success "Downloaded CHANGELOG.md"

# Create .gitignore entries if needed
if [ -f ".gitignore" ]; then
    # Add .runs/ if not present
    if ! grep -q ".runs/" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Droidz worktrees" >> .gitignore
        echo ".runs/" >> .gitignore
        log_success "Added .runs/ to .gitignore"
    fi
    
    # Add config.yml if not present (CRITICAL for security)
    if ! grep -q "config.yml" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Configuration file with API keys (NEVER commit this!)" >> .gitignore
        echo "config.yml" >> .gitignore
        echo "" >> .gitignore
        echo "# Keep the example template" >> .gitignore
        echo "!config.example.yml" >> .gitignore
        log_success "Added config.yml to .gitignore (keeps your API keys safe!)"
    fi
else
    # Create new .gitignore with both entries
    cat > .gitignore << 'EOF'
# Droidz worktrees
.runs/

# Configuration file with API keys (NEVER commit this!)
config.yml

# Keep the example template
!config.example.yml
EOF
    log_success "Created .gitignore with security settings"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$MODE" = "install" ]; then
    log_success "Droidz v${DROIDZ_VERSION} installed successfully! 🎉"
else
    log_success "Droidz updated to v${DROIDZ_VERSION}! 🎉"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Next steps
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Enable Custom Droids:"
echo "   droid"
echo "   /settings"
echo "   Toggle 'Custom Droids' ON"
echo ""
echo "2. Restart Factory:"
echo "   Exit (Ctrl+C) then run 'droid' again"
echo ""
echo "3. Verify droids loaded:"
echo "   /droids"
echo "   Should see: droidz-orchestrator, droidz-codegen, etc."
echo ""
echo "4. Add MCP servers (recommended):"
echo "   /mcp add exa      → AI search (exa.ai/api-keys)"
echo "   /mcp add linear   → Project management (linear.app/settings/api)"
echo "   /mcp add ref      → Documentation (ref.sh/api)"
echo ""
echo "   OR just set your Linear project in config.yml:"
echo "   linear:"
echo "     project_name: \"MyProject\""
echo ""
echo "5. Start building:"
echo "   droid"
echo "   Then say: Use droidz-orchestrator to build [your idea]"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Docs: README.md | CHANGELOG.md"
echo "💝 Support: paypal.me/leebarry84"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Happy building! 🚀🤖"
