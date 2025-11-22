#!/bin/bash
#
# Droidz Installer (Factory.ai Droid CLI Edition) - Smart Installer with Auto-Dependency Installation
#
# Install with (latest stable version):
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.2.2/install.sh | bash
#
# Or install from main branch (cutting edge):
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/korallis/Droidz/v3.2.2/install.sh
#   chmod +x install.sh
#   ./install.sh
#
# Version: 2.4.0-droid - Restore original 4-command workflow with all hotfixes
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

DROIDZ_VERSION="3.2.2"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/v${DROIDZ_VERSION}"
CACHE_BUST="?v=${DROIDZ_VERSION}&t=$(date +%s)"

# Installation mode (will be set by user choice)
INSTALL_MODE="" # "droid-cli", "claude-code", or "both"

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

# Detect Node.js package manager for the project
detect_node_package_manager() {
    # Check for lock files first (most reliable indicator)
    if [[ -f "pnpm-lock.yaml" ]]; then
        NODE_PKG_MANAGER="pnpm"
        log_info "Detected pnpm (found pnpm-lock.yaml)"
    elif [[ -f "yarn.lock" ]]; then
        NODE_PKG_MANAGER="yarn"
        log_info "Detected yarn (found yarn.lock)"
    elif [[ -f "package-lock.json" ]]; then
        NODE_PKG_MANAGER="npm"
        log_info "Detected npm (found package-lock.json)"
    elif [[ -f "bun.lockb" ]]; then
        NODE_PKG_MANAGER="bun"
        log_info "Detected bun (found bun.lockb)"
    # Fall back to checking which commands are available
    elif command -v pnpm &> /dev/null; then
        NODE_PKG_MANAGER="pnpm"
        log_info "Using pnpm (detected in PATH)"
    elif command -v yarn &> /dev/null; then
        NODE_PKG_MANAGER="yarn"
        log_info "Using yarn (detected in PATH)"
    elif command -v bun &> /dev/null; then
        NODE_PKG_MANAGER="bun"
        log_info "Using bun (detected in PATH)"
    elif command -v npm &> /dev/null; then
        NODE_PKG_MANAGER="npm"
        log_info "Using npm (detected in PATH)"
    else
        NODE_PKG_MANAGER="none"
        log_warning "No Node.js package manager found"
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
        echo "Node Package Manager: ${NODE_PKG_MANAGER:-not detected}"
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
echo -e "${CYAN}${BOLD}║   Droidz Framework Installer v${DROIDZ_VERSION}             ║${NC}"
echo -e "${CYAN}${BOLD}║   Production-Grade AI Development Framework         ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# INSTALLATION MODE SELECTION
# ============================================================================

# Check if this is an update (existing installation)
EXISTING_INSTALL=false
if [[ -d ".factory" ]] || [[ -d ".claude" ]]; then
    EXISTING_INSTALL=true
fi

# Only ask for mode if this is a fresh install
if [[ "$EXISTING_INSTALL" == "false" ]]; then
    log_step "Select Installation Mode"
    echo ""
    echo "Choose your AI development tool:"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${BOLD}Droid CLI${NC} (Factory.ai)"
    echo "     └─ Best for: Factory.ai Droid CLI users"
    echo "     └─ Folder: .factory/"
    echo ""
    echo -e "  ${GREEN}2)${NC} ${BOLD}Claude Code${NC} (Anthropic)"
    echo "     └─ Best for: Claude Code CLI users"
    echo "     └─ Folder: .claude/"
    echo ""
    echo -e "  ${GREEN}3)${NC} ${BOLD}Both${NC} (Install both modes)"
    echo "     └─ Best for: Using both tools"
    echo "     └─ Folders: .factory/ + .claude/"
    echo ""
    
    # Read mode choice with validation
    mode_choice=""
    while [[ -z "$mode_choice" ]]; do
        read -r -p "Enter your choice (1-3): " mode_choice < /dev/tty
        
        # Validate input
        if [[ ! "$mode_choice" =~ ^[1-3]$ ]]; then
            log_error "Invalid choice '$mode_choice'. Please enter 1, 2, or 3."
            mode_choice=""
        fi
    done
    echo ""
    
    case $mode_choice in
        1)
            INSTALL_MODE="droid-cli"
            log_info "Installing for Droid CLI (Factory.ai)"
            ;;
        2)
            log_warning "Claude Code installation not yet fully automated!"
            echo ""
            echo "Claude Code support coming in v3.3.0 with full automation."
            echo ""
            echo "For now, you can:"
            echo "  1) Install Droid CLI (option 1)"
            echo "  2) Follow manual setup guide:"
            echo "     https://github.com/korallis/Droidz/blob/main/CLAUDE_CODE_SETUP.md"
            echo ""
            read -r -p "Press Enter to return to menu..." < /dev/tty
            exit 0
            ;;
        3)
            log_warning "Dual installation coming soon in v3.3.0!"
            echo ""
            echo "For now, you can:"
            echo "  1) Install Droid CLI first (choose option 1)"
            echo "  2) Then manually copy .factory/ to .claude/ and rename files"
            echo "  3) Or wait for v3.3.0 with full dual-install support"
            echo ""
            read -r -p "Press Enter to return to menu..." < /dev/tty
            exit 0
            ;;
    esac
else
    # Detect existing installation type
    HAS_FACTORY=false
    HAS_CLAUDE=false
    
    if [[ -d ".factory" ]]; then
        HAS_FACTORY=true
    fi
    
    if [[ -d ".claude" ]]; then
        HAS_CLAUDE=true
    fi
    
    # Determine mode based on what exists
    if [[ "$HAS_FACTORY" == "true" ]] && [[ "$HAS_CLAUDE" == "true" ]]; then
        INSTALL_MODE="both"
        log_info "Detected both Droid CLI and Claude Code installations"
    elif [[ "$HAS_FACTORY" == "true" ]]; then
        # Show option to add Claude Code
        echo ""
        echo -e "${CYAN}${BOLD}🔍 Existing Installation Detected${NC}"
        echo ""
        echo "  Current: Droid CLI (.factory/)"
        echo ""
        echo "Would you like to:"
        echo ""
        echo -e "  ${GREEN}1)${NC} Update Droid CLI only"
        echo -e "  ${GREEN}2)${NC} Add Claude Code installation (keep Droid CLI)"
        echo ""
        
        existing_choice=""
        while [[ -z "$existing_choice" ]]; do
            read -r -p "Enter your choice (1-2): " existing_choice < /dev/tty
            
            if [[ ! "$existing_choice" =~ ^[1-2]$ ]]; then
                log_error "Invalid choice '$existing_choice'. Please enter 1 or 2."
                existing_choice=""
            fi
        done
        echo ""
        
        if [[ "$existing_choice" == "1" ]]; then
            INSTALL_MODE="droid-cli"
            log_info "Updating Droid CLI installation"
        else
            log_warning "Adding Claude Code to existing Droid CLI coming in v3.3.0!"
            echo ""
            echo "For now, manually copy .factory/ to .claude/ after installation."
            echo "See: https://github.com/korallis/Droidz/blob/main/CLAUDE_CODE_SETUP.md"
            echo ""
            read -r -p "Press Enter to continue with Droid CLI update only..." < /dev/tty
            INSTALL_MODE="droid-cli"
            log_info "Continuing with Droid CLI update"
        fi
    elif [[ "$HAS_CLAUDE" == "true" ]]; then
        # Show option to add Droid CLI
        echo ""
        echo -e "${CYAN}${BOLD}🔍 Existing Installation Detected${NC}"
        echo ""
        echo "  Current: Claude Code (.claude/)"
        echo ""
        echo "Would you like to:"
        echo ""
        echo -e "  ${GREEN}1)${NC} Update Claude Code only"
        echo -e "  ${GREEN}2)${NC} Add Droid CLI installation (keep Claude Code)"
        echo ""
        
        existing_choice=""
        while [[ -z "$existing_choice" ]]; do
            read -r -p "Enter your choice (1-2): " existing_choice < /dev/tty
            
            if [[ ! "$existing_choice" =~ ^[1-2]$ ]]; then
                log_error "Invalid choice '$existing_choice'. Please enter 1 or 2."
                existing_choice=""
            fi
        done
        echo ""
        
        if [[ "$existing_choice" == "1" ]]; then
            log_warning "Claude Code installation not yet supported!"
            echo ""
            echo "Claude Code support requires manual setup currently."
            echo "Please see: https://github.com/korallis/Droidz/blob/main/CLAUDE_CODE_SETUP.md"
            echo ""
            echo "Coming in v3.3.0: Full automated Claude Code installation"
            exit 1
        else
            log_warning "Adding Droid CLI to existing Claude Code coming in v3.3.0!"
            echo ""
            echo "For now, install Droid CLI separately in a different project."
            exit 1
        fi
    fi
fi

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

detect_os
log_step "Detected OS: $OS (Package manager: $PKG_MANAGER)"

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
                error_exit "Failed to install git. Please install manually: $(get_install_cmd git)" 1
            fi
        else
            error_exit "Install manually: $(get_install_cmd git)" 1
        fi
    else
        error_exit "Please install git manually" 1
    fi
else
    log_success "Git found"
fi

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

# Check for Bun runtime
if ! command -v bun >/dev/null 2>&1; then
    log_warning "Bun runtime not found. Required for running Droidz orchestration."
    log_info "Install from: https://bun.sh (or use: curl -fsSL https://bun.sh/install | bash)"
    echo ""
    log_warning "Continuing installation, but you'll need Bun to run orchestration."
    echo ""
fi

# Check for optional dependencies (jq and tmux)
# These are OPTIONAL - only needed for advanced orchestrator features
MISSING_DEPS=()

# Note: jq, tmux, and caffeinate are no longer required in v3.x
# Factory.ai Droid CLI handles all dependencies natively
# Keeping check code for backwards compatibility but not displaying

# Offer to install missing optional dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]] && [[ "$PKG_MANAGER" != "unknown" ]]; then
    echo ""
    log_info "Optional dependencies missing: ${MISSING_DEPS[*]}"
    log_info "Droidz will work without these. Only install if you need advanced orchestrator features."
    echo -e "${YELLOW}Install optional dependencies now?${NC}"
    read -p "Choice [y/N]: " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for dep in "${MISSING_DEPS[@]}"; do
            install_package "$dep"
        done
        echo ""
    else
        log_info "Skipping optional dependencies. You can install later if needed:"
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
        log_success "Continuing installation without optional dependencies"
    fi
fi

# Function to completely remove Droidz
uninstall_droidz() {
    log_warning "This will completely remove Droidz from this project"
    echo ""
    echo "The following will be removed:"
    echo "  • .factory/ directory and all contents"
    echo "  • config.yml (your API keys and settings)"
    echo "  • Droidz dependencies from package.json"
    echo ""
    read -p "Are you sure you want to uninstall? (yes/no): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        log_step "Uninstalling Droidz..."
        
        # Remove .factory directory
        if [[ -d ".factory" ]]; then
            rm -rf .factory
            log_success "Removed .factory/ directory"
        fi
        
        # Remove config.yml
        if [[ -f "config.yml" ]]; then
            rm -f config.yml
            log_success "Removed config.yml"
        fi
        
        # Remove Droidz-specific dependencies
        if command -v bun >/dev/null 2>&1 && [[ -f "package.json" ]]; then
            bun remove yaml >/dev/null 2>&1 || true
            log_success "Removed Droidz dependencies"
        fi
        
        echo ""
        log_success "Droidz has been completely uninstalled"
        echo ""
        echo "To reinstall later, run:"
        echo "  curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.2.2/install.sh | bash"
        exit 0
    else
        log_info "Uninstall cancelled"
        exit 0
    fi
}

# Detect if this is an install or update (check for .factory directory)
# Also detect v2.x installations (.droidz folder)
V2_DETECTED=false
if [[ -d ".droidz" ]]; then
    V2_DETECTED=true
fi

if [[ -d ".factory" ]] || [[ "$V2_DETECTED" == "true" ]]; then
    echo ""
    if [[ "$V2_DETECTED" == "true" ]]; then
        log_warning "Droidz v2.x installation detected (.droidz/ folder found)"
        echo ""
        echo -e "${YELLOW}${BOLD}🔄 MIGRATION AVAILABLE: v2.x → v3.x${NC}"
        echo ""
        echo "  Droidz v3.0+ uses .factory/ instead of .droidz/"
        echo "  Migration will:"
        echo "    • Move specs from .droidz/specs/ → .factory/specs/active/"
        echo "    • Update .gitignore patterns"
        echo "    • Preserve all your work"
        echo "    • Remove old .droidz/ folder"
        echo ""
    else
        log_warning "Existing Droidz installation detected"
    fi
    
    # Always show menu and wait for user input
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "  1) Update (keep existing configuration and memory)"
    echo "  2) Fresh Install (remove old installation and start clean)"
    echo "  3) Uninstall (completely remove Droidz)"
    if [[ "$V2_DETECTED" == "true" ]]; then
        echo "  4) Migrate from v2.x to v3.x (recommended for v2.x users)"
        echo "  5) Cancel"
        MAX_CHOICE=5
    else
        echo "  4) Cancel"
        MAX_CHOICE=4
    fi
    echo ""
    
    # Read user choice with validation (force read from terminal, not script stdin)
    choice=""
    while [[ -z "$choice" ]]; do
        read -r -p "Enter your choice (1-${MAX_CHOICE}): " choice < /dev/tty
        
        # Validate input
        if [[ ! "$choice" =~ ^[1-${MAX_CHOICE}]$ ]]; then
            log_error "Invalid choice '$choice'. Please enter 1-${MAX_CHOICE}."
            choice=""
        fi
    done
    echo ""
    
    case $choice in
        1)
            MODE="update"
            log_info "Updating existing Droidz installation to v${DROIDZ_VERSION}..."
            ;;
        2)
            MODE="fresh"
            log_warning "Performing fresh installation..."
            log_info "Backing up config.yml if it exists..."
            
            # Backup config.yml
            if [[ -f "config.yml" ]]; then
                cp config.yml config.yml.backup
                log_success "Backed up config.yml to config.yml.backup"
            fi
            
            # Remove old installation
            log_info "Removing old Droidz installation..."
            rm -rf .factory
            rm -rf .droidz  # Also remove v2.x folder if present
            log_success "Old installation removed"
            
            # Restore config.yml
            if [[ -f "config.yml.backup" ]]; then
                mv config.yml.backup config.yml
                log_success "Restored config.yml"
            fi
            
            log_info "Installing fresh copy of Droidz v${DROIDZ_VERSION}..."
            ;;
        3)
            uninstall_droidz
            ;;
        4)
            if [[ "$V2_DETECTED" == "true" ]]; then
                # Run migration
                log_info "Starting migration from v2.x to v3.x..."
                echo ""
                
                # Download migration script
                MIGRATE_SCRIPT=".factory/scripts/migrate-v3.sh"
                mkdir -p .factory/scripts
                
                log_step "Downloading migration script..."
                if curl -fsSL "${GITHUB_RAW}/.factory/scripts/migrate-v3.sh${CACHE_BUST}" -o "${MIGRATE_SCRIPT}"; then
                    chmod +x "${MIGRATE_SCRIPT}"
                    log_success "Migration script downloaded"
                    echo ""
                    
                    # Run migration
                    log_info "Running migration..."
                    bash "${MIGRATE_SCRIPT}"
                    
                    # Continue with update installation
                    MODE="update"
                    log_info "Continuing with Droidz v${DROIDZ_VERSION} installation..."
                else
                    log_error "Failed to download migration script"
                    log_info "You can manually run migration later with:"
                    echo "  .factory/scripts/migrate-v3.sh"
                    exit 1
                fi
            else
                log_info "Installation cancelled"
                exit 0
            fi
            ;;
        5)
            log_info "Installation cancelled"
            exit 0
            ;;
    esac
else
    MODE="install"
    log_info "Installing Droidz v${DROIDZ_VERSION}..."
fi

echo ""

# Create directories (Droid CLI only for now)
log_step "Creating directories..."
mkdir -p .factory/droids
mkdir -p .factory/commands
mkdir -p .factory/orchestrator
mkdir -p .factory/hooks
mkdir -p .factory/memory/user
mkdir -p .factory/memory/org
mkdir -p .factory/skills
mkdir -p .factory/specs/active
mkdir -p .factory/specs/archive
mkdir -p .factory/specs/templates
mkdir -p .factory/product
mkdir -p .factory/scripts
mkdir -p .factory/standards/templates
log_success "Directories created"

# Handle package.json based on installation mode
if [[ "$MODE" == "update" ]]; then
    # UPDATE MODE: Use existing setup, don't ask about package manager
    if [[ ! -f "package.json" ]]; then
        log_warning "package.json not found but this is an update. Creating with npm..."
        npm init -y >/dev/null 2>&1
        log_success "Created package.json"
    else
        log_info "package.json detected – preserving existing settings"
    fi
else
    # FRESH INSTALL or NEW INSTALL: Ask for package manager choice
    if [[ ! -f "package.json" ]]; then
        log_info "package.json not found. Need to create one..."
        echo ""
        echo "Which package manager would you like to use?"
        echo ""
        echo "  1) npm   - Node.js default (comes with Node.js)"
        echo "  2) yarn  - Fast, reliable (install: npm install -g yarn)"
        echo "  3) pnpm  - Disk space efficient (install: npm install -g pnpm)"
        echo "  4) bun   - Ultra-fast (install: curl -fsSL https://bun.sh/install | bash)"
        echo ""
        
        # Read package manager choice with validation (force read from terminal)
        pkg_choice=""
        while [[ -z "$pkg_choice" ]]; do
            read -r -p "Enter your choice (1-4): " pkg_choice < /dev/tty
            
            # Validate input
            if [[ ! "$pkg_choice" =~ ^[1-4]$ ]]; then
                log_error "Invalid choice '$pkg_choice'. Please enter 1, 2, 3, or 4."
                pkg_choice=""
            fi
        done
        echo ""
        
        # Map choice to package manager
        case $pkg_choice in
            1)
                CHOSEN_PKG_MANAGER="npm"
                ;;
            2)
                CHOSEN_PKG_MANAGER="yarn"
                ;;
            3)
                CHOSEN_PKG_MANAGER="pnpm"
                ;;
            4)
                CHOSEN_PKG_MANAGER="bun"
                ;;
        esac
        
        # Check if chosen package manager is available
        if ! command -v "$CHOSEN_PKG_MANAGER" &> /dev/null; then
            log_error "$CHOSEN_PKG_MANAGER is not installed!"
            echo ""
            echo "Installation instructions:"
            case $CHOSEN_PKG_MANAGER in
                npm)
                    echo "  npm comes with Node.js: https://nodejs.org"
                    ;;
                yarn)
                    echo "  npm install -g yarn"
                    echo "  Or: https://yarnpkg.com/getting-started/install"
                    ;;
                pnpm)
                    echo "  npm install -g pnpm"
                    echo "  Or: curl -fsSL https://get.pnpm.io/install.sh | sh -"
                    ;;
                bun)
                    echo "  curl -fsSL https://bun.sh/install | bash"
                    ;;
            esac
            exit 1
        fi
        
        # Initialize package.json with chosen package manager
        log_info "Initializing package.json with $CHOSEN_PKG_MANAGER..."
        case $CHOSEN_PKG_MANAGER in
            npm)
                npm init -y >/dev/null 2>&1
                ;;
            yarn)
                yarn init -y >/dev/null 2>&1
                ;;
            pnpm)
                pnpm init >/dev/null 2>&1
                ;;
            bun)
                bun init -y >/dev/null 2>&1
                ;;
        esac
        log_success "Initialized package.json with $CHOSEN_PKG_MANAGER"
        
        # Set NODE_PKG_MANAGER to the chosen one
        NODE_PKG_MANAGER="$CHOSEN_PKG_MANAGER"
    else
        log_info "package.json detected – preserving existing settings"
    fi
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

# Detect Node.js package manager
detect_node_package_manager

# Install runtime and linting dependencies
if [[ "$NODE_PKG_MANAGER" == "none" ]]; then
    log_error "No Node.js package manager found. Please install npm, yarn, pnpm, or bun first."
    echo ""
    echo "Installation options:"
    echo "  npm:  comes with Node.js (https://nodejs.org)"
    echo "  yarn: npm install -g yarn"
    echo "  pnpm: npm install -g pnpm"
    echo "  bun:  curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

log_step "Installing dependencies using ${NODE_PKG_MANAGER}..."

# Check if yaml is already installed
YAML_INSTALLED=false
if [[ -f "package.json" ]]; then
    if grep -q '"yaml"' package.json 2>/dev/null; then
        YAML_INSTALLED=true
        log_info "yaml dependency already in package.json"
    fi
fi

# Install dependencies based on detected package manager
case "$NODE_PKG_MANAGER" in
    npm)
        if [[ "$YAML_INSTALLED" == "false" ]]; then
            log_info "Installing runtime dependency: yaml"
            if npm install yaml --save 2>&1 | tee /tmp/npm-install.log | grep -q "error"; then
                log_error "Failed to install yaml dependency"
                echo ""
                echo "npm error output:"
                cat /tmp/npm-install.log
                echo ""
                log_warning "This might be a workspace/monorepo project with install restrictions"
                log_info "You may need to add 'yaml' manually to your root package.json"
                rm -f /tmp/npm-install.log
            else
                log_success "Added yaml dependency"
                rm -f /tmp/npm-install.log
            fi
        fi
        
        log_info "Installing development dependencies for linting and types"
        if npm install --save-dev @types/node @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint typescript-eslint 2>/dev/null; then
            log_success "Installed development dependencies"
        else
            log_warning "Could not install dev dependencies (might be workspace restrictions)"
        fi
        ;;
    yarn)
        if [[ "$YAML_INSTALLED" == "false" ]]; then
            log_info "Installing runtime dependency: yaml"
            if yarn add yaml 2>&1 | tee /tmp/yarn-install.log | grep -q "error"; then
                log_error "Failed to install yaml dependency"
                echo ""
                echo "yarn error output:"
                cat /tmp/yarn-install.log
                echo ""
                log_warning "This might be a workspace/monorepo project with install restrictions"
                rm -f /tmp/yarn-install.log
            else
                log_success "Added yaml dependency"
                rm -f /tmp/yarn-install.log
            fi
        fi
        
        log_info "Installing development dependencies for linting and types"
        if yarn add -D @types/node @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint typescript-eslint 2>/dev/null; then
            log_success "Installed development dependencies"
        else
            log_warning "Could not install dev dependencies (might be workspace restrictions)"
        fi
        ;;
    pnpm)
        if [[ "$YAML_INSTALLED" == "false" ]]; then
            log_info "Installing runtime dependency: yaml"
            if pnpm add yaml 2>&1 | tee /tmp/pnpm-install.log | grep -q "error"; then
                log_error "Failed to install yaml dependency"
                echo ""
                echo "pnpm error output:"
                cat /tmp/pnpm-install.log
                echo ""
                log_warning "This might be a workspace/monorepo project with install restrictions"
                rm -f /tmp/pnpm-install.log
            else
                log_success "Added yaml dependency"
                rm -f /tmp/pnpm-install.log
            fi
        fi
        
        log_info "Installing development dependencies for linting and types"
        if pnpm add -D @types/node @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint typescript-eslint 2>/dev/null; then
            log_success "Installed development dependencies"
        else
            log_warning "Could not install dev dependencies (might be workspace restrictions)"
        fi
        ;;
    bun)
        if [[ "$YAML_INSTALLED" == "false" ]]; then
            log_info "Installing runtime dependency: yaml"
            if bun add yaml 2>&1 | tee /tmp/bun-install.log | grep -q "error"; then
                log_error "Failed to install yaml dependency"
                echo ""
                echo "bun error output:"
                cat /tmp/bun-install.log
                echo ""
                log_warning "This might be a workspace/monorepo project with install restrictions"
                rm -f /tmp/bun-install.log
            else
                log_success "Added yaml dependency"
                rm -f /tmp/bun-install.log
            fi
        fi
        
        log_info "Installing development dependencies for linting and types"
        if bun add -d @types/bun @types/node @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint typescript-eslint 2>/dev/null; then
            log_success "Installed development dependencies"
        else
            log_warning "Could not install dev dependencies (might be workspace restrictions)"
        fi
        ;;
esac

# Download droids
log_step "Downloading robot helpers (droids)..."

DROIDS=(
    "droidz-orchestrator.md"
    "droidz-codegen.md"
    "droidz-test.md"
    "droidz-refactor.md"
    "droidz-infra.md"
    "droidz-integration.md"
    "droidz-generalist.md"
    "droidz-ui-designer.md"
    "droidz-ux-designer.md"
    "droidz-database-architect.md"
    "droidz-api-designer.md"
    "droidz-security-auditor.md"
    "droidz-performance-optimizer.md"
    "droidz-accessibility-specialist.md"
)

for droid in "${DROIDS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/droids/${droid}${CACHE_BUST}" -o ".factory/droids/${droid}"
    log_success "Downloaded ${droid}"
done

# Backup existing commands if updating
if [[ -d ".factory/commands" ]] && [[ "$MODE" == "update" ]]; then
    BACKUP_DIR=".factory-commands-backup-$(date +%s)"
    cp -r .factory/commands "$BACKUP_DIR"
    log_info "Backed up existing commands to $BACKUP_DIR"
fi

# Download custom commands
log_step "Downloading custom slash commands..."

# Remove old command files with deprecated names (during updates)
if [[ "$MODE" == "update" ]]; then
    log_info "Removing old command files..."
    rm -f .factory/commands/droidz-init.md 2>/dev/null || true
    rm -f .factory/commands/auto-parallel.md 2>/dev/null || true
    rm -f .factory/commands/droidz-build.md 2>/dev/null || true
    rm -f .factory/commands/*.v2-backup 2>/dev/null || true
    log_success "Old command files removed"
fi

COMMANDS=(
    "init.md"
    "build.md"
    "parallel.md"
    "gh-helper.md"
    "validate-init.md"
    "validate.md"
)

for command in "${COMMANDS[@]}"; do
    curl -fsSL "${GITHUB_RAW}/.factory/commands/${command}${CACHE_BUST}" -o ".factory/commands/${command}"
    log_success "Downloaded ${command}"
done

# Download gh-helper script
curl -fsSL "${GITHUB_RAW}/.factory/commands/gh-helper.sh${CACHE_BUST}" -o ".factory/commands/gh-helper.sh"
chmod +x ".factory/commands/gh-helper.sh"
log_success "Downloaded gh-helper.sh"

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

# Download all skills (new format: subdirectory/SKILL.md)
log_step "Downloading skills..."

SKILL_NAMES=(
    "ADAPTATION_GUIDE"
    "api-documentation-generator"
    "auto-orchestrator"
    "brainstorming"
    "changelog-generator"
    "ci-cd-pipelines"
    "clerk"
    "cloudflare-workers"
    "code-review-checklist"
    "condition-based-waiting"
    "context-optimizer"
    "convex"
    "defense-in-depth"
    "design"
    "dispatching-parallel-agents"
    "docker-containerization"
    "drizzle"
    "environment-management"
    "executing-plans"
    "finishing-a-development-branch"
    "git-commit-messages"
    "graphite-stacked-diffs"
    "graphql-api-design"
    "load-testing"
    "memory-manager"
    "monitoring-observability"
    "neon"
    "nextjs-16"
    "performance-profiler"
    "postgresql"
    "pr-description-generator"
    "prisma"
    "react"
    "readme-generator"
    "receiving-code-review"
    "requesting-code-review"
    "root-cause-tracing"
    "security"
    "security-audit-checklist"
    "sharing-skills"
    "spec-shaper"
    "standards-enforcer"
    "stripe"
    "subagent-driven-development"
    "supabase"
    "systematic-debugging"
    "tailwind-v4"
    "tanstack-query"
    "tech-stack-analyzer"
    "test-driven-development"
    "testing-anti-patterns"
    "testing-skills-with-subagents"
    "trpc"
    "typescript"
    "unit-test-generator"
    "using-droidz"
    "using-git-worktrees"
    "vercel"
    "verification-before-completion"
    "websocket-realtime"
    "writing-skills"
)

for skill in "${SKILL_NAMES[@]}"; do
    mkdir -p ".factory/skills/${skill}"
    if curl -fsSL "${GITHUB_RAW}/.factory/skills/${skill}/SKILL.md${CACHE_BUST}" -o ".factory/skills/${skill}/SKILL.md" 2>/dev/null; then
        log_success "Downloaded ${skill} skill"
    else
        log_warning "Could not download ${skill} skill (may not exist on remote yet)"
    fi
done

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

# Documentation is maintained in the repository
# Users should reference GitHub for CHANGELOG and updates
log_step "Framework files installed successfully"

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
    echo -e "${GREEN}${BOLD}║   🎉 Droidz v${DROIDZ_VERSION} Installation Complete!         ║${NC}"
else
    echo -e "${GREEN}${BOLD}║   🎉 Droidz Updated to v${DROIDZ_VERSION}!                   ║${NC}"
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
echo "5. Explore the 4-command workflow:"
echo "   /droidz-init      → Smart onboarding & project analysis"
echo "   /droidz-build     → AI spec generator with visual diagrams"
echo "   /auto-parallel    → Parallel task execution"
echo "   /gh-helper        → GitHub CLI operations"
echo ""
echo "6. Start building:"
echo "   droid"
echo "   Then say: Use droidz-orchestrator to build [your idea]"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ What's New in Factory.ai Edition:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• Skills enabled by default (45+ skills ready out-of-the-box)"
echo "• Auto-activation hooks for proactive assistance"
echo "• Memory management for decisions and patterns"
echo "• Advanced skills (TDD, systematic-debugging, graphite, etc.)"
echo "• Standards enforcement with auto-fix"
echo "• Context optimization and monitoring"
echo "• Product vision and roadmap templates"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Docs: https://github.com/korallis/Droidz"
echo "💝 Support: paypal.me/gideonapp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Happy building! 🚀🤖"
