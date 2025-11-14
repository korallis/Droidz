#!/bin/bash
#
# Droidz Installer (Factory.ai Droid CLI Edition) - Smart Installer with Auto-Dependency Installation
#
# Install with:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh
#   chmod +x install.sh
#   ./install.sh
#
# Version: 2.2.6-droid - WSL compatibility + UX improvements + Orchestrator fixes
# Features:
#   - Detects OS and package manager (apt, dnf, yum, pacman, zypper, apk, brew)
#   - Auto-installs missing dependencies (git, jq, tmux, Bun) with user permission
#   - Offers to initialize git repository if not already in one
#   - WSL auto-configuration for Factory.ai Droid CLI compatibility
#   - Comprehensive error logging with system diagnostics
#   - Fixed installer to only download existing files (no 404 errors)
#   - Improved orchestrator UX (clean output instead of verbose Execute commands)
# Updated: November 14, 2025
#

set -euo pipefail
IFS=$'\n\t'

DROIDZ_VERSION="2.2.6-droid"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/factory-ai"
CACHE_BUST="?v=${DROIDZ_VERSION}&t=$(date +%s)"

# Error logging
ERROR_LOG_FILE=".droidz-install-$(date +%Y%m%d_%H%M%S).log"
INSTALL_START_TIME=$(date +%s)

# Colors for output - only if output is to a terminal
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    local msg="$*"
    echo -e "${YELLOW}⚠${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> "$ERROR_LOG_FILE"
}

log_error() {
    local msg="$*"
    echo -e "${RED}✗${NC} $msg" >&2
    # Also log to file with timestamp
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> "$ERROR_LOG_FILE"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}▸ $*${NC}"
    # Log steps to file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STEP: $*" >> "$ERROR_LOG_FILE"
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
            [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
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
            if ! command -v brew &> /dev/null; then
                log_error "Homebrew is required to install $package_name automatically. Install it from https://brew.sh and re-run."
                return 1
            fi
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

SHELL_PROFILE=""

determine_shell_profile() {
    if [[ -n "$SHELL_PROFILE" ]]; then
        return
    fi

    local current_shell
    current_shell=$(basename "${SHELL:-}")
    local candidates=()

    case "$current_shell" in
        zsh)
            candidates=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.profile")
            ;;
        bash)
            candidates=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
            ;;
        *)
            candidates=("$HOME/.profile")
            ;;
    esac

    for candidate in "${candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            SHELL_PROFILE="$candidate"
            return
        fi
    done

    SHELL_PROFILE="${candidates[0]}"
    touch "$SHELL_PROFILE"
}

append_profile_block() {
    local identifier="$1"
    local content="$2"

    determine_shell_profile

    if [[ -z "$SHELL_PROFILE" ]]; then
        return
    fi

    if grep -q "$identifier" "$SHELL_PROFILE" 2>/dev/null; then
        return
    fi

    {
        echo ""
        echo "# Added by Droidz installer ($identifier) on $(date '+%Y-%m-%d %H:%M:%S')"
        printf "%b\n" "$content"
    } >> "$SHELL_PROFILE"

    log_success "Updated $(basename "$SHELL_PROFILE") with $identifier settings"
}

reload_shell_profile() {
    determine_shell_profile

    if [[ -n "$SHELL_PROFILE" && -f "$SHELL_PROFILE" ]]; then
        set +u
        # shellcheck disable=SC1090
        . "$SHELL_PROFILE"
        set -u
    fi
}

ensure_nvm_loaded() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        set +u
        # shellcheck disable=SC1090
        . "$NVM_DIR/nvm.sh"
        set -u
        return 0
    fi

    return 1
}

ensure_bun_path() {
    local bun_dir="$HOME/.bun/bin"

    if [[ -d "$bun_dir" ]]; then
        if [[ ":$PATH:" != *":$bun_dir:"* ]]; then
            export PATH="$bun_dir:$PATH"
        fi
        append_profile_block "DROIDZ_BUN_PATH" 'export PATH="$HOME/.bun/bin:$PATH"'
        reload_shell_profile
    fi
}

install_nvm_dependency() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    if [[ -d "$NVM_DIR" ]]; then
        ensure_nvm_loaded
        return 0
    fi

    log_info "Installing nvm (Node Version Manager)..."
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
        append_profile_block "DROIDZ_NVM" $'export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"\ncommand -v nvm >/dev/null 2>&1 && nvm use default >/dev/null 2>&1 || true'
        reload_shell_profile
        ensure_nvm_loaded
        return 0
    fi

    return 1
}

install_bun_dependency() {
    log_info "Installing Bun runtime..."

    if command -v brew &> /dev/null; then
        if brew install oven-sh/bun/bun; then
            ensure_bun_path
            return 0
        fi
    else
        if curl -fsSL https://bun.sh/install | bash; then
            ensure_bun_path
            return 0
        fi
    fi

    return 1
}

install_git_dependency() {
    install_package git
}

install_jq_dependency() {
    install_package jq
}

install_tmux_dependency() {
    install_package tmux
}

install_node_lts() {
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        return 0
    fi

    if ! ensure_nvm_loaded; then
        if ! install_nvm_dependency; then
            return 1
        fi
    fi

    if command -v nvm &> /dev/null; then
        log_info "Installing Node.js LTS via nvm..."
        if nvm install --lts; then
            nvm alias default 'lts/*' >/dev/null 2>&1 || true
            nvm use default >/dev/null 2>&1 || true
            reload_shell_profile
            return 0
        fi
    fi

    return 1
}

prepare_command_check() {
    local cmd="$1"

    case "$cmd" in
        nvm)
            ensure_nvm_loaded >/dev/null 2>&1 || true
            ;;
        node|npm)
            ensure_nvm_loaded >/dev/null 2>&1 || true
            if command -v nvm >/dev/null 2>&1; then
                nvm use default >/dev/null 2>&1 || true
            fi
            ;;
        *)
            ;;
    esac
}

ensure_dependency() {
    local command="$1"
    local friendly="$2"
    local installer_fn="$3"
    local manual_hint="$4"
    local mandatory="${5:-true}"
    local prompt_message="${6:-}"

    prepare_command_check "$command"

    if command -v "$command" >/dev/null 2>&1; then
        log_success "$friendly found"
        return 0
    fi

    log_warning "$friendly not found."

    if [[ -n "$installer_fn" ]]; then
        if [[ -n "$prompt_message" ]]; then
            echo -e "$prompt_message"
        else
            echo -e "${YELLOW}Install $friendly now?${NC}"
        fi
        read -p "Choice [Y/n]: " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            if "$installer_fn"; then
                prepare_command_check "$command"
                if command -v "$command" >/dev/null 2>&1; then
                    log_success "$friendly installed"
                    return 0
                fi
            else
                log_error "Automatic installation of $friendly failed."
            fi
        fi
    fi

    if [[ -n "$manual_hint" ]]; then
        log_info "Manual install instructions: $manual_hint"
    fi

    if [[ "$mandatory" == "true" ]]; then
        error_exit "$friendly is required. Please install it and rerun the installer." 1
    fi

    return 1
}

generate_error_report() {
    local exit_code="${1:-1}"
    local install_end_time=$(date +%s)
    local duration=$((install_end_time - INSTALL_START_TIME))

    echo ""
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║   Installation Failed - Error Report Generated      ║${NC}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
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

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Installation failed with exit code $exit_code"
        generate_error_report "$exit_code"
    else
        # Clean up log file on success
        if [[ -f "$ERROR_LOG_FILE" ]]; then
            rm -f "$ERROR_LOG_FILE"
        fi
    fi
}

trap cleanup EXIT
trap 'log_error "Installation interrupted by user"; exit 130' INT TERM

error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# ============================================================================
# INSTALLATION PROCESS
# ============================================================================

# Display welcome banner
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   Droidz Factory.ai Installer v${DROIDZ_VERSION}            ║${NC}"
echo -e "${CYAN}${BOLD}║   Smart Update with Auto-Dependency Installation    ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

detect_os
log_step "Detected OS: $OS (Package manager: $PKG_MANAGER)"

ensure_dependency "git" "Git" install_git_dependency "$(get_install_cmd git)"

ensure_dependency "bun" "Bun runtime" install_bun_dependency "Install via: curl -fsSL https://bun.sh/install | bash" true "${YELLOW}Bun runtime is missing and required. Install automatically now?${NC}"

# Ensure Node/npm via nvm or existing installation
ensure_dependency "node" "Node.js (LTS)" install_node_lts "Install Node.js LTS via https://nodejs.org or use nvm install --lts" true "${YELLOW}Node.js is missing. Install Node LTS via nvm now?${NC}"

ensure_dependency "npm" "npm" install_node_lts "Install Node.js LTS (includes npm) via nvm install --lts" true "${YELLOW}npm is missing. Install Node LTS via nvm now?${NC}"

# Ensure nvm is available (optional but recommended)
ensure_dependency "nvm" "nvm (Node Version Manager)" install_nvm_dependency "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash" false "${YELLOW}nvm not detected. Install nvm (recommended for managing Node)?${NC}"

# Check if we're in a git repo
if [[ ! -d ".git" ]]; then
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
            if [[ ! -f ".gitignore" ]]; then
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
            error_exit "Failed to initialize git repository. Please run 'git init' manually." 1
        fi
    else
        error_exit "Please initialize git manually with: git init" 1
    fi
else
    log_success "Git repository detected"
fi

ensure_dependency "jq" "jq" install_jq_dependency "$(get_install_cmd jq)" false "${YELLOW}jq not found. Install automatically now?${NC}"

ensure_dependency "tmux" "tmux" install_tmux_dependency "$(get_install_cmd tmux)" false "${YELLOW}tmux not found. Install automatically now?${NC}"

# Check for caffeinate on macOS (prevents sleep during long operations)
if [[ "$OS" == "macos" ]]; then
    if ! command -v caffeinate &> /dev/null; then
        log_warning "caffeinate not found. Prevents Mac from sleeping during operations."
        log_info "caffeinate is a macOS system utility (usually pre-installed)"
    else
        log_success "caffeinate found"
    fi
fi

# Detect if this is an install or update
if [[ -d ".factory/droids" ]] && [[ -f ".factory/orchestrator/task-coordinator.ts" ]]; then
    MODE="update"
    log_info "Existing Droidz installation detected. Updating..."
else
    MODE="install"
    log_info "Installing Droidz v${DROIDZ_VERSION}..."
fi

echo ""

# Create directories
log_step "Creating directories..."
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
if [[ ! -f "package.json" ]]; then
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
log_step "Downloading robot helpers (droids)..."

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
log_step "Downloading custom slash commands..."

COMMANDS=(
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
log_step "Downloading orchestrator scripts..."

ORCHESTRATOR_FILES=(
    "worktree-setup.ts"
    "task-coordinator.ts"
    "types.ts"
    "config.json"
    "tsconfig.json"
)

for file in "${ORCHESTRATOR_FILES[@]}"; do
    if [[ "$file" = "config.json" ]]; then
        tmp_file=$(mktemp)
        curl -fsSL "${GITHUB_RAW}/.factory/orchestrator/${file}${CACHE_BUST}" -o "$tmp_file"

        target_file=".factory/orchestrator/${file}"

        if [[ ! -f "$target_file" ]]; then
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
log_step "Downloading configuration template..."
curl -fsSL "${GITHUB_RAW}/config.example.yml${CACHE_BUST}" -o "config.example.yml"
log_success "Downloaded config.example.yml"

# Handle config.yml
if [[ -f "config.yml" ]]; then
    log_warning "config.yml already exists - preserving your existing configuration"
    log_info "Compare with config.example.yml to see new simplified settings"
else
    cp config.example.yml config.yml
    log_success "Created config.yml from template"
    log_info "Simple config - just set your Linear project name (optional)"
fi

# Download hooks
log_step "Downloading hooks..."

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
log_step "Downloading memory templates..."
curl -fsSL "${GITHUB_RAW}/.factory/memory/user/README.md${CACHE_BUST}" -o ".factory/memory/user/README.md"
log_success "Downloaded user memory template"

curl -fsSL "${GITHUB_RAW}/.factory/memory/org/README.md${CACHE_BUST}" -o ".factory/memory/org/README.md"
log_success "Downloaded org memory template"

# Download skills
log_step "Downloading skills..."

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
log_step "Downloading nested skills..."

curl -fsSL "${GITHUB_RAW}/.factory/skills/auto-orchestrator/SKILL.md${CACHE_BUST}" -o ".factory/skills/auto-orchestrator/SKILL.md"
log_success "Downloaded auto-orchestrator skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/memory-manager/SKILL.md${CACHE_BUST}" -o ".factory/skills/memory-manager/SKILL.md"
log_success "Downloaded memory-manager skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/graphite-stacked-diffs/SKILL.md${CACHE_BUST}" -o ".factory/skills/graphite-stacked-diffs/SKILL.md"
log_success "Downloaded graphite-stacked-diffs skill"

curl -fsSL "${GITHUB_RAW}/.factory/skills/spec-shaper/SKILL.md${CACHE_BUST}" -o ".factory/skills/spec-shaper/SKILL.md"
log_success "Downloaded spec-shaper skill"

# Download spec templates
log_step "Downloading spec templates..."
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
log_step "Downloading product documentation..."

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
log_step "Downloading scripts..."
curl -fsSL "${GITHUB_RAW}/.factory/scripts/orchestrator.sh${CACHE_BUST}" -o ".factory/scripts/orchestrator.sh"
chmod +x ".factory/scripts/orchestrator.sh"
log_success "Downloaded orchestrator.sh"

# Download standards templates
log_step "Downloading standards templates..."

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
log_step "Downloading settings.json..."
if [[ -f ".factory/settings.json" ]]; then
    log_warning "settings.json already exists - preserving your configuration"
    log_info "Compare with the latest version to see new settings"
else
    curl -fsSL "${GITHUB_RAW}/.factory/settings.json${CACHE_BUST}" -o ".factory/settings.json"
    log_success "Downloaded settings.json"
fi

# Download documentation (keep local README untouched)
log_step "Downloading documentation updates..."
curl -fsSL "${GITHUB_RAW}/CHANGELOG.md${CACHE_BUST}" -o "CHANGELOG.md"
log_success "Downloaded CHANGELOG.md"

# Create .gitignore entries if needed
if [[ -f ".gitignore" ]]; then
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
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
if [[ "$MODE" = "install" ]]; then
    echo -e "${GREEN}${BOLD}║   🎉 Droidz v${DROIDZ_VERSION} Installation Complete!          ║${NC}"
else
    echo -e "${GREEN}${BOLD}║   🎉 Droidz Updated to v${DROIDZ_VERSION}!                    ║${NC}"
fi
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
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
