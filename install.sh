#!/bin/bash
set -e

# Droidz Installer
# Installs or updates Droidz in your project
# Updated: 2025-01-10 - Simplified MCP setup

DROIDZ_VERSION="2.0.1"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/main"

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
if [ -d ".factory/droids" ] && [ -f "orchestrator/linear-fetch.ts" ]; then
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
mkdir -p orchestrator
mkdir -p docs
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
    curl -fsSL "${GITHUB_RAW}/.factory/droids/${droid}" -o ".factory/droids/${droid}"
    log_success "Downloaded ${droid}"
done

# Download orchestrator scripts
log_info "Downloading orchestrator scripts..."

SCRIPTS=(
    "linear-fetch.ts"
    "linear-update.ts"
    "worktree-setup.ts"
    "task-coordinator.ts"
)

for script in "${SCRIPTS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/orchestrator/${script}" -o "orchestrator/${script}"
    log_success "Downloaded ${script}"
done

# Make scripts executable
chmod +x orchestrator/*.ts 2>/dev/null || true

# Download config.example.yml template
log_info "Downloading configuration template..."
curl -fsSL "${GITHUB_RAW}/config.example.yml" -o "config.example.yml"
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

DOCS=(
    "QUICK_START_V2.md"
    "CHANGELOG.md"
)

for doc in "${DOCS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/${doc}" -o "${doc}"
    log_success "Downloaded ${doc}"
done

# Download architecture docs
curl -fsSL "${GITHUB_RAW}/docs/V2_ARCHITECTURE.md" -o "docs/V2_ARCHITECTURE.md"
log_success "Downloaded architecture documentation"

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
echo "📋 Next Steps:"
echo ""
echo "1. Enable Custom Droids in Factory:"
echo "   ${BLUE}droid${NC}"
echo "   ${BLUE}/settings${NC}"
echo "   Toggle 'Custom Droids' ON"
echo ""
echo "2. Restart Factory:"
echo "   Exit (Ctrl+C or /quit) and run ${BLUE}droid${NC} again"
echo ""
echo "3. Verify droids loaded:"
echo "   ${BLUE}/droids${NC}"
echo "   You should see: droidz-orchestrator, droidz-codegen, etc."
echo ""
echo "4. Add MCP servers (recommended):"
echo "   ${BLUE}/mcp add exa${NC}      # AI search"
echo "   ${BLUE}/mcp add linear${NC}   # Project management"
echo "   ${BLUE}/mcp add ref${NC}      # Documentation"
echo "   ${YELLOW}Get API keys: exa.ai, linear.app/settings/api, ref.sh${NC}"
echo ""
echo "   ${GREEN}OR${NC} just set your Linear project name in config.yml:"
echo "   ${BLUE}linear:${NC}"
echo "   ${BLUE}  project_name: \"MyProject\"${NC}"
echo ""
echo "5. Start building:"
echo "   ${BLUE}droid${NC}"
echo "   Then say:"
echo "   ${GREEN}Use droidz-orchestrator to build [your idea]${NC}"
echo ""
echo "📚 Documentation:"
echo "   - Quick Start: QUICK_START_V2.md"
echo "   - Architecture: docs/V2_ARCHITECTURE.md"
echo "   - Changelog: CHANGELOG.md"
echo ""
echo "💝 Like Droidz? Consider supporting:"
echo "   https://paypal.me/leebarry84"
echo ""
echo "Happy building! 🚀🤖"
