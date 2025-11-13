#!/bin/bash
set -e

# Droidz Installer (Factory.ai Droid CLI Edition) - Auto-Dependency Installation + Git Init
# Installs or updates Droidz in your project
# Updated: 2025-11-12 - Auto-installs dependencies + git repo initialization

DROIDZ_VERSION="2.2.1-droid"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/factory-ai"
CACHE_BUST="?v=${DROIDZ_VERSION}&t=$(date +%s)"

# Error logging
ERROR_LOG_FILE=".droidz-install-$(date +%Y%m%d_%H%M%S).log"
INSTALL_START_TIME=$(date +%s)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    local msg="$1"
    echo -e "${BLUE}ℹ${NC} $msg"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    local msg="$1"
    echo -e "${YELLOW}⚠${NC} $msg"
    # Also log to file with timestamp
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> "$ERROR_LOG_FILE"
}

log_error() {
    local msg="$1"
    echo -e "${RED}✗${NC} $msg"
    # Also log to file with timestamp
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> "$ERROR_LOG_FILE"
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
        configure_wsl_for_claude_code
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

configure_wsl_for_claude_code() {
    echo ""
    log_info "Configuring WSL2 for Claude Code compatibility..."

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log_warning "npm not found. Node.js installation required for Claude Code."
        echo ""
        return 0
    fi

    # Check if npm is pointing to Windows installation
    local npm_path
    npm_path=$(which npm 2>/dev/null || echo "")

    if [[ "$npm_path" == /mnt/c/* ]]; then
        log_warning "Detected Windows npm in WSL. Claude Code requires Linux Node.js."
        log_info "Please install Node.js via nvm for WSL:"
        echo ""
        echo -e "${CYAN}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash${NC}"
        echo -e "${CYAN}source ~/.bashrc${NC}"
        echo -e "${CYAN}nvm install --lts${NC}"
        echo ""
        log_warning "Continuing installation, but Claude Code may not work until Node.js is installed in WSL."
        echo ""
        return 0
    fi

    # Configure npm for Linux platform
    log_info "Setting npm platform to 'linux' for WSL2 compatibility..."
    if npm config set os linux 2>/dev/null; then
        log_success "npm configured to treat environment as Linux"
    else
        log_warning "Could not configure npm platform (may require manual configuration)"
    fi

    # Verify nvm is properly loaded
    if command -v nvm &> /dev/null || [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        log_success "nvm detected - Node.js environment ready"

        # Source nvm if not already loaded
        if ! command -v nvm &> /dev/null && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
            log_info "Loading nvm for current session..."
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            log_success "nvm loaded"
        fi
    else
        log_info "nvm not detected (optional but recommended for WSL2)"
    fi

    log_success "WSL2 configuration complete"
    log_info "When installing Claude Code, use: npm install -g @anthropic-ai/claude-code --force --no-os-check"
    echo ""
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

generate_error_report() {
    local exit_code="${1:-1}"
    local install_end_time=$(date +%s)
    local duration=$((install_end_time - INSTALL_START_TIME))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_error "Installation Failed - Error Report Generated"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Append system info to log
    {
        echo ""
        echo "=========================================="
        echo "SYSTEM INFORMATION"
        echo "=========================================="
        echo "Date: $(date)"
        echo "Exit Code: $exit_code"
        echo "Duration: ${duration}s"
        echo "OS Type: $OSTYPE"
        echo "Detected OS: ${OS:-unknown}"
        echo "Package Manager: ${PKG_MANAGER:-unknown}"
        echo "Shell: $SHELL"
        echo "User: $USER"
        echo ""
        echo "=========================================="
        echo "ENVIRONMENT"
        echo "=========================================="
        echo "Working Directory: $(pwd)"
        echo "Git Available: $(command -v git &>/dev/null && echo "yes" || echo "no")"
        if command -v git &>/dev/null; then
            echo "Git Version: $(git --version 2>/dev/null || echo "unknown")"
            echo "In Git Repo: $(git rev-parse --git-dir &>/dev/null && echo "yes" || echo "no")"
        fi
        echo "Bun Available: $(command -v bun &>/dev/null && echo "yes" || echo "no")"
        if command -v bun &>/dev/null; then
            echo "Bun Version: $(bun --version 2>/dev/null || echo "unknown")"
        fi
        echo "npm Available: $(command -v npm &>/dev/null && echo "yes" || echo "no")"
        if command -v npm &>/dev/null; then
            echo "npm Version: $(npm --version 2>/dev/null || echo "unknown")"
            echo "npm Path: $(which npm 2>/dev/null || echo "unknown")"
        fi
        echo "node Available: $(command -v node &>/dev/null && echo "yes" || echo "no")"
        if command -v node &>/dev/null; then
            echo "node Version: $(node --version 2>/dev/null || echo "unknown")"
            echo "node Path: $(which node 2>/dev/null || echo "unknown")"
        fi
        echo "nvm Available: $(command -v nvm &>/dev/null && echo "yes" || [[ -s "$HOME/.nvm/nvm.sh" ]] && echo "installed but not loaded" || echo "no")"
        echo ""
        echo "=========================================="
        echo "INSTALLED DEPENDENCIES"
        echo "=========================================="
        echo "jq: $(command -v jq &>/dev/null && jq --version 2>/dev/null || echo "not installed")"
        echo "tmux: $(command -v tmux &>/dev/null && tmux -V 2>/dev/null || echo "not installed")"
        if [[ "$OS" == "macos" ]]; then
            echo "caffeinate: $(command -v caffeinate &>/dev/null && echo "available" || echo "not available")"
        fi
        echo ""
        if [[ "$OS" == "wsl2" ]]; then
            echo "=========================================="
            echo "WSL SPECIFIC INFO"
            echo "=========================================="
            echo "WSL Version Info:"
            cat /proc/version 2>/dev/null || echo "Could not read /proc/version"
            echo ""
            echo "Windows PATH in use: $([[ "$PATH" == */mnt/c/* ]] && echo "yes" || echo "no")"
        fi
    } >> "$ERROR_LOG_FILE"

    echo -e "${CYAN}Error log saved to: ${NC}$ERROR_LOG_FILE"
    echo ""
    echo -e "${YELLOW}Please share this file when reporting the issue:${NC}"
    echo -e "  ${BLUE}1.${NC} Open an issue at: ${CYAN}https://github.com/korallis/Droidz/issues${NC}"
    echo -e "  ${BLUE}2.${NC} Copy and paste the contents of: $ERROR_LOG_FILE"
    echo ""
    echo -e "${CYAN}Quick copy command:${NC}"
    if command -v pbcopy &>/dev/null; then
        echo -e "  cat $ERROR_LOG_FILE | pbcopy  # Then paste with Cmd+V"
    elif command -v xclip &>/dev/null; then
        echo -e "  cat $ERROR_LOG_FILE | xclip -selection clipboard"
    else
        echo -e "  cat $ERROR_LOG_FILE  # Then copy manually"
    fi
    echo ""
}

# Trap errors
trap 'EXIT_CODE=$?; if [ $EXIT_CODE -ne 0 ]; then generate_error_report $EXIT_CODE; fi' EXIT

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

# Check for caffeinate on macOS (prevents sleep during long operations)
if [[ "$OS" == "macos" ]]; then
    if ! command -v caffeinate &> /dev/null; then
        log_warning "caffeinate not found. Prevents Mac from sleeping during operations."
        log_info "caffeinate is a macOS system utility (usually pre-installed)"
    else
        log_success "caffeinate found"
    fi
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
mkdir -p .factory/hooks
mkdir -p .factory/memory/user
mkdir -p .factory/memory/org
mkdir -p .factory/skills/auto-orchestrator
mkdir -p .factory/skills/memory-manager
mkdir -p .factory/skills/graphite-stacked-diffs
mkdir -p .factory/skills/spec-shaper
mkdir -p .factory/specs/active
mkdir -p .factory/specs/archive
mkdir -p .factory/specs/templates
mkdir -p .factory/product
mkdir -p .factory/scripts
mkdir -p .factory/standards/templates
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
    "droidz-init.md"
    "graphite.md"
    "orchestrate.md"
    "spec-shaper.md"
    "validate-spec.md"
    "create-spec.md"
    "analyze-tech-stack.md"
    "save-decision.md"
    "spec-to-tasks.md"
    "auto-orchestrate.md"
    "optimize-context.md"
    "check-standards.md"
    "load-memory.md"
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

# Download hooks
log_info "Downloading hooks..."

HOOKS=(
    "auto-lint.sh"
    "monitor-context.sh"
)

for hook in "${HOOKS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/hooks/${hook}${CACHE_BUST}" -o ".factory/hooks/${hook}"
    chmod +x ".factory/hooks/${hook}"
    log_success "Downloaded ${hook}"
done

# Download memory templates
log_info "Downloading memory templates..."
curl -fsSL "${GITHUB_RAW}/.factory/memory/user/README.md${CACHE_BUST}" -o ".factory/memory/user/README.md"
log_success "Downloaded user memory template"

curl -fsSL "${GITHUB_RAW}/.factory/memory/org/README.md${CACHE_BUST}" -o ".factory/memory/org/README.md"
log_success "Downloaded org memory template"

# Download skills
log_info "Downloading skills..."

SKILLS=(
    "standards-enforcer.md"
    "context-optimizer.md"
    "tech-stack-analyzer.md"
)

for skill in "${SKILLS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/skills/${skill}${CACHE_BUST}" -o ".factory/skills/${skill}"
    log_success "Downloaded ${skill}"
done

# Download nested skills (with subdirectories)
log_info "Downloading nested skills..."

curl -fsSL "${GITHUB_RAW}/.factory/skills/auto-orchestrator/SKILL.md${CACHE_BUST}" -o ".factory/skills/auto-orchestrator/SKILL.md"
log_success "Downloaded auto-orchestrator skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/memory-manager/SKILL.md${CACHE_BUST}" -o ".factory/skills/memory-manager/SKILL.md"
log_success "Downloaded memory-manager skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/graphite-stacked-diffs/SKILL.md${CACHE_BUST}" -o ".factory/skills/graphite-stacked-diffs/SKILL.md"
log_success "Downloaded graphite-stacked-diffs skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/spec-shaper/SKILL.md${CACHE_BUST}" -o ".factory/skills/spec-shaper/SKILL.md"
log_success "Downloaded spec-shaper skill"

# Download spec templates
log_info "Downloading spec templates..."
curl -fsSL "${GITHUB_RAW}/.factory/specs/README.md${CACHE_BUST}" -o ".factory/specs/README.md"
log_success "Downloaded specs README"

curl -fsSL "${GITHUB_RAW}/.factory/specs/templates/feature-spec.md${CACHE_BUST}" -o ".factory/specs/templates/feature-spec.md"
log_success "Downloaded feature-spec template"

curl -fsSL "${GITHUB_RAW}/.factory/specs/templates/epic-spec.md${CACHE_BUST}" -o ".factory/specs/templates/epic-spec.md"
log_success "Downloaded epic-spec template"

# Create .gitkeep files for empty directories
touch .factory/specs/active/.gitkeep
touch .factory/specs/archive/.gitkeep

# Download product documentation
log_info "Downloading product documentation..."

PRODUCT_FILES=(
    "vision.md"
    "use-cases.md"
    "roadmap.md"
)

for file in "${PRODUCT_FILES[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/product/${file}${CACHE_BUST}" -o ".factory/product/${file}"
    log_success "Downloaded ${file}"
done

# Download scripts
log_info "Downloading scripts..."
curl -fsSL "${GITHUB_RAW}/.factory/scripts/orchestrator.sh${CACHE_BUST}" -o ".factory/scripts/orchestrator.sh"
chmod +x ".factory/scripts/orchestrator.sh"
log_success "Downloaded orchestrator.sh"

# Download standards templates
log_info "Downloading standards templates..."

STANDARDS=(
    "typescript.md"
    "react.md"
    "nextjs.md"
    "vue.md"
    "shadcn-ui.md"
    "convex.md"
    "tailwind.md"
    "python.md"
)

for standard in "${STANDARDS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/standards/templates/${standard}${CACHE_BUST}" -o ".factory/standards/templates/${standard}"
    log_success "Downloaded ${standard} standard"
done

# Download settings.json (main configuration)
log_info "Downloading settings.json..."
if [ -f ".factory/settings.json" ]; then
    log_warning "settings.json already exists - preserving your configuration"
    log_info "Compare with the latest version to see new settings"
else
    curl -fsSL "${GITHUB_RAW}/.factory/settings.json${CACHE_BUST}" -o ".factory/settings.json"
    log_success "Downloaded settings.json"
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

# Clean up log file on success
if [[ -f "$ERROR_LOG_FILE" ]]; then
    rm -f "$ERROR_LOG_FILE"
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
echo "5. Explore new features:"
echo "   /commands         → See all available slash commands"
echo "   /spec-shaper      → Create structured specs for features"
echo "   /auto-orchestrate → Auto-detect and orchestrate complex tasks"
echo "   /graphite         → Manage stacked diffs workflow"
echo "   /analyze-tech-stack → Analyze project tech stack"
echo "   /load-memory      → Load saved decisions and patterns"
echo ""
echo "6. Start building:"
echo "   droid"
echo "   Then say: Use droidz-orchestrator to build [your idea]"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ What's New in Factory.ai Edition:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• Auto-activation hooks for proactive assistance"
echo "• Memory management for decisions and patterns"
echo "• Advanced skills (spec-shaper, auto-orchestrator, etc.)"
echo "• Standards enforcement with auto-fix"
echo "• Context optimization and monitoring"
echo "• Product vision and roadmap templates"
echo "• 100% feature parity with Claude Code"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Docs: README.md | CHANGELOG.md"
echo "💝 Support: paypal.me/gideonapp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Happy building! 🚀🤖"
