#!/bin/bash
set -e

# Droidz Installer - Auto-Dependency Installation + Git Init
# Installs or updates Droidz in your project
# Updated: 2025-11-12 - Auto-installs dependencies + git repo initialization

DROIDZ_VERSION="2.2.1"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/main"
CACHE_BUST="?v=${DROIDZ_VERSION}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# ============================================================================
# OS AND PACKAGE MANAGER DETECTION
# ============================================================================

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
        OS="wsl2"
        detect_package_manager
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        detect_package_manager
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
    elif command -v apk &> /dev/null; then
        PKG_MANAGER="apk"
    else
        PKG_MANAGER="unknown"
    fi
}

get_install_cmd() {
    local package="$1"
    case "$PKG_MANAGER" in
        brew)
            echo "brew install $package"
            ;;
        apt)
            echo "sudo apt update && sudo apt install -y $package"
            ;;
        dnf)
            echo "sudo dnf install -y $package"
            ;;
        yum)
            echo "sudo yum install -y $package"
            ;;
        pacman)
            echo "sudo pacman -S --noconfirm $package"
            ;;
        zypper)
            echo "sudo zypper install -y $package"
            ;;
        apk)
            echo "sudo apk add --update $package"
            ;;
        *)
            echo "Please install $package manually"
            ;;
    esac
}

install_package() {
    local command_name="$1"
    local package_name="${2:-$1}"

    log_info "Installing $package_name..."

    if command -v "$command_name" &> /dev/null; then
        log_success "$command_name is already installed"
        return 0
    fi

    local install_result=1
    case "$PKG_MANAGER" in
        brew)
            brew install "$package_name" &> /dev/null && install_result=0
            ;;
        apt)
            sudo apt-get update -y &> /dev/null && sudo apt-get install -y "$package_name" &> /dev/null && install_result=0
            ;;
        dnf)
            sudo dnf install -y "$package_name" &> /dev/null && install_result=0
            ;;
        yum)
            sudo yum install -y "$package_name" &> /dev/null && install_result=0
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package_name" &> /dev/null && install_result=0
            ;;
        zypper)
            sudo zypper install -y "$package_name" &> /dev/null && install_result=0
            ;;
        apk)
            sudo apk add --update "$package_name" &> /dev/null && install_result=0
            ;;
        *)
            log_error "No supported package manager found"
            return 1
            ;;
    esac

    if [[ $install_result -eq 0 ]] && command -v "$command_name" &> /dev/null; then
        log_success "$command_name installed successfully"
        return 0
    else
        log_error "Failed to install $command_name"
        log_info "Please install manually: $(get_install_cmd "$package_name")"
        return 1
    fi
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

detect_os
log_info "Detected OS: $OS (Package manager: $PKG_MANAGER)"

# Check for git (CRITICAL)
if ! command -v git &> /dev/null; then
    log_error "Git is not installed."

    if [[ "$PKG_MANAGER" != "unknown" ]]; then
        echo ""
        echo -e "${YELLOW}Git is required. Install now?${NC}"
        read -p "Choice [Y/n]: " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            if ! install_package git; then
                log_error "Failed to install git. Please install manually: $(get_install_cmd git)"
                exit 1
            fi
        else
            log_info "Install manually: $(get_install_cmd git)"
            exit 1
        fi
    else
        log_error "Please install git manually"
        exit 1
    fi
else
    log_success "Git found"
fi

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    log_warning "Not in a git repository."
    echo ""
    echo -e "${YELLOW}Would you like to initialize this directory as a git repository?${NC}"
    echo -e "  ${CYAN}[Y]${NC} Yes, initialize git repository (recommended)"
    echo -e "  ${CYAN}[N]${NC} No, I'll do it manually"
    echo ""
    read -p "Choice [Y/n]: " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        log_info "Initializing git repository..."
        if git init > /dev/null 2>&1; then
            log_success "Git repository initialized"

            # Create initial .gitignore if it doesn't exist
            if [ ! -f ".gitignore" ]; then
                cat > .gitignore << 'EOF'
# Droidz worktrees
.runs/

# Configuration file with API keys (NEVER commit this!)
config.yml

# Keep the example template
!config.example.yml

# Dependency artifacts
node_modules/
bun.lockb

# Common ignores
.DS_Store
*.log
EOF
                log_success "Created .gitignore"
            fi

            # Create initial commit
            git add .gitignore > /dev/null 2>&1
            if git commit -m "chore: initialize repository with Droidz framework" > /dev/null 2>&1; then
                log_success "Created initial commit"
            else
                log_info "Repository initialized (no initial commit created)"
            fi
        else
            log_error "Failed to initialize git repository. Please run 'git init' manually."
            exit 1
        fi
    else
        log_info "Please initialize git manually with: git init"
        exit 1
    fi
else
    log_success "Git repository detected"
fi

# Check for Bun runtime
if ! command -v bun >/dev/null 2>&1; then
    log_warning "Bun runtime not found. Required for running Droidz orchestration."
    log_info "Install from: https://bun.sh (or use: curl -fsSL https://bun.sh/install | bash)"
    echo ""
    log_warning "Continuing installation, but you'll need Bun to run orchestration."
    echo ""
fi

# Check for optional dependencies (jq and tmux)
MISSING_DEPS=()

if ! command -v jq &> /dev/null; then
    log_warning "jq not found. Required for orchestration features."
    MISSING_DEPS+=("jq")
else
    log_success "jq found"
fi

if ! command -v tmux &> /dev/null; then
    log_warning "tmux not found. Required for parallel task monitoring."
    MISSING_DEPS+=("tmux")
else
    log_success "tmux found"
fi

# Offer to install missing optional dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]] && [[ "$PKG_MANAGER" != "unknown" ]]; then
    echo ""
    log_warning "Missing optional dependencies: ${MISSING_DEPS[*]}"
    echo -e "${YELLOW}Install these now for full orchestration support?${NC}"
    read -p "Choice [Y/n]: " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        for dep in "${MISSING_DEPS[@]}"; do
            install_package "$dep"
        done
        echo ""
    else
        log_info "You can install later with:"
        case "$PKG_MANAGER" in
            apt)
                log_info "  sudo apt update && sudo apt install -y ${MISSING_DEPS[*]}"
                ;;
            brew)
                log_info "  brew install ${MISSING_DEPS[*]}"
                ;;
            *)
                for dep in "${MISSING_DEPS[@]}"; do
                    log_info "  $(get_install_cmd "$dep")"
                done
                ;;
        esac
        echo ""
    fi
fi

# Detect if this is an install or update
if [ -d ".factory/droids" ] && [ -f ".factory/orchestrator/task-coordinator.ts" ]; then
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
mkdir -p .factory/orchestrator
log_success "Directories created"

# Ensure package.json exists
if [ ! -f "package.json" ]; then
    log_info "package.json not found. Initializing Bun project..."
    bun init --yes >/dev/null 2>&1
    log_success "Initialized package.json"
else
    log_info "package.json detected – preserving existing settings"
fi

# Ensure package.json uses ESM modules
if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import json
from pathlib import Path

path = Path("package.json")
pkg = json.loads(path.read_text())
updated = False

if pkg.get("type") != "module":
    pkg["type"] = "module"
    updated = True

if updated:
    path.write_text(json.dumps(pkg, indent=2) + "\n")
PY
    log_success "Ensured package.json is configured for ES modules"
else
    log_warning "python3 not found. Please ensure package.json includes \"type\": \"module\"."
fi

# Install runtime and linting dependencies
log_info "Installing runtime dependency: yaml"
bun add yaml >/dev/null 2>&1
log_success "Added yaml dependency"

log_info "Installing development dependencies for linting and types"
bun add -d @types/bun @types/node @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint typescript-eslint >/dev/null 2>&1
log_success "Installed development dependencies"

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

ORCHESTRATOR_FILES=(
    "worktree-setup.ts"
    "task-coordinator.ts"
    "types.ts"
    "config.json"
    "tsconfig.json"
)

for file in "${ORCHESTRATOR_FILES[@]}"; do
    if [ "$file" = "config.json" ]; then
        tmp_file=$(mktemp)
        curl -fsSL "${GITHUB_RAW}/.factory/orchestrator/${file}${CACHE_BUST}" -o "$tmp_file"

        target_file=".factory/orchestrator/${file}"

        if [ ! -f "$target_file" ]; then
            mv "$tmp_file" "$target_file"
            log_success "Downloaded ${file}"
        else
            if command -v python3 >/dev/null 2>&1; then
                python3 - "$tmp_file" "$target_file" <<'PY'
import json
import sys
from pathlib import Path

default_path = Path(sys.argv[1])
current_path = Path(sys.argv[2])

default_cfg = json.loads(default_path.read_text())
current_cfg = json.loads(current_path.read_text())

def merge(default, current):
    if isinstance(default, dict) and isinstance(current, dict):
        for key, value in default.items():
            if key not in current:
                current[key] = value
            else:
                current[key] = merge(value, current[key])
        return current
    return current

merged = merge(default_cfg, current_cfg)
current_path.write_text(json.dumps(merged, indent=2) + "\n")
PY
                log_success "Updated ${file} with new defaults"
            else
                log_warning "python3 not found. Skipping merge for ${file}; existing customization preserved."
            fi
            rm -f "$tmp_file"
        fi
    else
        curl -fsSL "${GITHUB_RAW}/.factory/orchestrator/${file}${CACHE_BUST}" -o ".factory/orchestrator/${file}"
        log_success "Downloaded ${file}"
    fi
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

# Download documentation (keep local README untouched)
log_info "Downloading documentation updates..."
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

    # Ensure dependencies are ignored
    if ! grep -q "node_modules/" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Dependency artifacts" >> .gitignore
        echo "node_modules/" >> .gitignore
        log_success "Added node_modules/ to .gitignore"
    fi

    if ! grep -q "bun.lockb" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "bun.lockb" >> .gitignore
        log_success "Added bun.lockb to .gitignore"
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

# Dependency artifacts
node_modules/
bun.lockb
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
echo "   /mcp add exa      → AI/code research (authenticate when prompted)"
echo "   /mcp add linear   → Project management (follow MCP auth flow)"
echo "   /mcp add ref      → Documentation lookup (CLI will guide you)"
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
echo "💝 Support: paypal.me/gideonapp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Happy building! 🚀🤖"
