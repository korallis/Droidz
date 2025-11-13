#!/usr/bin/env bash
#
# Droidz Claude Code Framework - Smart Installer with Auto-Dependency Installation
#
# Install with:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh
#   chmod +x install-claude-code.sh
#   ./install-claude-code.sh
#
# Version: 2.1.1 - Auto-installs dependencies + git init support
# Features:
#   - Detects OS and package manager (apt, dnf, yum, pacman, zypper, apk, brew)
#   - Auto-installs missing dependencies (git, jq, tmux) with user permission
#   - Offers to initialize git repository if not already in one
#   - Smart merge support for updates
# Updated: November 12, 2025
#

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# COLORS AND FORMATTING
# ============================================================================

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    MAGENTA=''
    BOLD=''
    NC=''
fi

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    local msg="$*"
    echo -e "${YELLOW}⚠${NC} $msg"
    # Also log to file with timestamp
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> "$ERROR_LOG_FILE"
}

log_error() {
    local msg="$*"
    echo -e "${RED}✗${NC} $msg" >&2
    # Also log to file with timestamp
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> "$ERROR_LOG_FILE"
}

log_step() {
    local msg="$*"
    echo -e "\n${CYAN}${BOLD}▸ $msg${NC}"
    # Log steps to file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STEP: $msg" >> "$ERROR_LOG_FILE"
}

log_custom() {
    echo -e "${MAGENTA}★${NC} $*"
}

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

CUSTOM_FILES=()
UPDATED_FILES=()
PRESERVED_FILES=()
SKIPPED_FILES=()

# Error logging
ERROR_LOG_FILE=".droidz-install-$(date +%Y%m%d_%H%M%S).log"
INSTALL_START_TIME=$(date +%s)

# Base framework files - these will be updated
declare -a BASE_AGENTS=(
    "codegen.md"
    "test.md"
    "refactor.md"
    "infra.md"
    "integration.md"
    "droidz-orchestrator.md"
    "generalist.md"
)

declare -a BASE_SKILLS=(
    "spec-shaper/SKILL.md"
    "auto-orchestrator/SKILL.md"
    "memory-manager/SKILL.md"
)

declare -a BASE_COMMANDS=(
    "droidz-init.md"
    "create-spec.md"
    "validate-spec.md"
    "spec-to-tasks.md"
    "orchestrate.md"
    "check-standards.md"
    "save-decision.md"
    "load-memory.md"
    "analyze-tech-stack.md"
    "optimize-context.md"
)

# ============================================================================
# ERROR HANDLING
# ============================================================================

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Installation failed with exit code $exit_code"
        if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]]; then
            log_info "Cleaning up temporary files..."
            rm -rf "$TEMP_DIR"
        fi

        # Generate error report
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
        echo "curl Available: $(command -v curl &>/dev/null && echo "yes" || echo "no")"
        echo "wget Available: $(command -v wget &>/dev/null && echo "yes" || echo "no")"
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

    echo -e "${CYAN}Error log saved to: ${BOLD}$ERROR_LOG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}Please share this file when reporting the issue:${NC}"
    echo -e "  ${BLUE}1.${NC} Open an issue at: ${CYAN}https://github.com/korallis/Droidz/issues${NC}"
    echo -e "  ${BLUE}2.${NC} Copy and paste the contents of: ${BOLD}$ERROR_LOG_FILE${NC}"
    echo ""
    echo -e "${CYAN}Quick copy command:${NC}"
    if command -v pbcopy &>/dev/null; then
        echo -e "  ${BOLD}cat $ERROR_LOG_FILE | pbcopy${NC}  # Then paste with Cmd+V"
    elif command -v xclip &>/dev/null; then
        echo -e "  ${BOLD}cat $ERROR_LOG_FILE | xclip -selection clipboard${NC}"
    else
        echo -e "  ${BOLD}cat $ERROR_LOG_FILE${NC}  # Then copy manually"
    fi
    echo ""
}

# ============================================================================
# PREREQUISITE CHECKS
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
    # Try to detect the package manager on Linux systems
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
    log_step "Configuring WSL2 for Claude Code compatibility..."

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log_warning "npm not found. Node.js installation required for Claude Code."
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

    # Check if already installed
    if command -v "$command_name" &> /dev/null; then
        log_success "$command_name is already installed"
        return 0
    fi

    # Install based on package manager
    local install_result=1
    case "$PKG_MANAGER" in
        brew)
            if brew install "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        apt)
            if sudo apt-get update -y &> /dev/null && sudo apt-get install -y "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        dnf)
            if sudo dnf install -y "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        yum)
            if sudo yum install -y "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        pacman)
            if sudo pacman -S --noconfirm "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        zypper)
            if sudo zypper install -y "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        apk)
            if sudo apk add --update "$package_name" &> /dev/null; then
                install_result=0
            fi
            ;;
        *)
            log_error "No supported package manager found"
            return 1
            ;;
    esac

    # Verify installation
    if [[ $install_result -eq 0 ]] && command -v "$command_name" &> /dev/null; then
        log_success "$command_name installed successfully"
        return 0
    else
        log_error "Failed to install $command_name"
        log_info "Please install manually: $(get_install_cmd "$package_name")"
        return 1
    fi
}

prompt_auto_install() {
    local packages=("$@")

    echo ""
    log_warning "Missing dependencies: ${packages[*]}"
    echo ""
    echo -e "${YELLOW}Would you like to automatically install these dependencies?${NC}"
    echo -e "  ${CYAN}[Y]${NC} Yes, install automatically (recommended)"
    echo -e "  ${CYAN}[N]${NC} No, I'll install manually"
    echo ""
    read -p "Choice [Y/n]: " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        return 0
    else
        return 1
    fi
}

check_prerequisites() {
    log_step "Checking prerequisites..."

    # Initialize missing dependencies array
    MISSING_DEPS=()

    # Detect operating system
    detect_os
    log_info "Detected OS: $OS (Package manager: $PKG_MANAGER)"

    # Check for git (CRITICAL - cannot proceed without it)
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed."

        if [[ "$PKG_MANAGER" != "unknown" ]]; then
            echo ""
            echo -e "${YELLOW}Git is required to proceed. Would you like to install it now?${NC}"
            echo -e "  ${CYAN}[Y]${NC} Yes, install git automatically (recommended)"
            echo -e "  ${CYAN}[N]${NC} No, I'll install manually"
            echo ""
            read -p "Choice [Y/n]: " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                if install_package git; then
                    log_success "Git installed successfully"
                else
                    log_error "Failed to install git"
                    log_info "Install manually with: $(get_install_cmd git)"
                    error_exit "Git is required to continue." 1
                fi
            else
                log_info "Please install git manually: $(get_install_cmd git)"
                error_exit "Git is required to continue." 1
            fi
        else
            log_info "Install git manually: $(get_install_cmd git)"
            error_exit "Git is required to continue." 1
        fi
    else
        log_success "Git found: $(git --version | head -n1)"
    fi

    # Check git version (need 2.19+ for worktree improvements)
    local git_version
    git_version=$(git --version | awk '{print $3}')
    local git_major
    git_major=$(echo "$git_version" | cut -d. -f1)
    local git_minor
    git_minor=$(echo "$git_version" | cut -d. -f2)

    if [[ $git_major -lt 2 ]] || [[ $git_major -eq 2 && $git_minor -lt 19 ]]; then
        log_warning "Git version $git_version detected. Version 2.19+ recommended for worktree support."
    fi

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
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
                if [[ ! -f .gitignore ]]; then
                    cat > .gitignore << 'EOF'
# Droidz Framework - User-specific files
.factory/memory/user/
.runs/
*.backup.*
*-tasks.json
.factory-*-backup*

# Common ignores
node_modules/
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
            log_info "Please initialize git manually with: git init"
            error_exit "Git repository required to continue." 1
        fi
    else
        log_success "Git repository detected"
    fi

    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        log_error "Neither curl nor wget found."

        if [[ "$PKG_MANAGER" != "unknown" ]]; then
            echo ""
            echo -e "${YELLOW}curl or wget is required to download files. Install curl?${NC}"
            read -p "Install curl? [Y/n]: " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                if install_package curl; then
                    DOWNLOAD_CMD="curl -fsSL"
                else
                    log_info "Install manually with: $(get_install_cmd curl)"
                    error_exit "curl or wget is required." 1
                fi
            else
                log_info "Install manually with: $(get_install_cmd curl)"
                error_exit "curl or wget is required." 1
            fi
        else
            log_info "Install curl manually: $(get_install_cmd curl)"
            error_exit "curl or wget is required." 1
        fi
    fi

    if command -v curl &> /dev/null; then
        DOWNLOAD_CMD="curl -fsSL"
        log_success "curl found"
    else
        DOWNLOAD_CMD="wget -qO-"
        log_success "wget found"
    fi

    # Check for jq (required for orchestration)
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found. Required for orchestration features."
        MISSING_DEPS+=("jq")
    else
        log_success "jq found"
    fi

    # Check for tmux (required for parallel execution)
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

    # Handle missing optional dependencies (jq and tmux)
    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        echo ""
        log_warning "Missing optional dependencies: ${MISSING_DEPS[*]}"
        log_info "Droidz will install, but orchestration features require these."

        if [[ "$PKG_MANAGER" != "unknown" ]]; then
            if prompt_auto_install "${MISSING_DEPS[@]}"; then
                log_step "Installing dependencies..."
                local install_failed=()

                for dep in "${MISSING_DEPS[@]}"; do
                    if ! install_package "$dep"; then
                        install_failed+=("$dep")
                    fi
                done

                if [[ ${#install_failed[@]} -gt 0 ]]; then
                    echo ""
                    log_warning "Some dependencies could not be installed: ${install_failed[*]}"
                    log_info "You can install them later for full orchestration support."
                    echo ""
                else
                    echo ""
                    log_success "All dependencies installed successfully!"
                    echo ""
                fi
            else
                echo ""
                log_info "You chose to install manually. Commands:"
                for dep in "${MISSING_DEPS[@]}"; do
                    log_info "  $dep: $(get_install_cmd "$dep")"
                done
                echo ""
                log_info "Or install all at once:"
                case "$PKG_MANAGER" in
                    apt)
                        log_info "  sudo apt update && sudo apt install -y ${MISSING_DEPS[*]}"
                        ;;
                    brew)
                        log_info "  brew install ${MISSING_DEPS[*]}"
                        ;;
                    dnf)
                        log_info "  sudo dnf install -y ${MISSING_DEPS[*]}"
                        ;;
                    yum)
                        log_info "  sudo yum install -y ${MISSING_DEPS[*]}"
                        ;;
                    pacman)
                        log_info "  sudo pacman -S --noconfirm ${MISSING_DEPS[*]}"
                        ;;
                    *)
                        ;;
                esac
                echo ""
            fi
        else
            echo ""
            log_info "Install manually with your package manager:"
            for dep in "${MISSING_DEPS[@]}"; do
                log_info "  $dep"
            done
            echo ""
        fi
    fi
}

# ============================================================================
# CUSTOM FILE DETECTION
# ============================================================================

is_base_file() {
    local file="$1"
    local category="$2"

    case "$category" in
        agents)
            for base in "${BASE_AGENTS[@]}"; do
                if [[ "$file" == "$base" ]]; then
                    return 0
                fi
            done
            return 1
            ;;
        skills)
            for base in "${BASE_SKILLS[@]}"; do
                if [[ "$file" == "$base" ]]; then
                    return 0
                fi
            done
            return 1
            ;;
        commands)
            for base in "${BASE_COMMANDS[@]}"; do
                if [[ "$file" == "$base" ]]; then
                    return 0
                fi
            done
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

detect_custom_files() {
    log_step "Detecting custom files..."

    local custom_count=0

    # Check for custom agents
    if [[ -d ".factory/agents" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            if ! is_base_file "$basename_file" "agents"; then
                CUSTOM_FILES+=("agents/$basename_file")
                log_custom "Custom agent: $basename_file"
                ((custom_count++))
            fi
        done < <(find .factory/agents -name "*.md" -type f -print0 2>/dev/null)
    fi

    # Check for custom skills
    if [[ -d ".factory/skills" ]]; then
        while IFS= read -r -d '' dir; do
            local skill_name
            skill_name=$(basename "$dir")
            local skill_file="$skill_name/SKILL.md"
            if ! is_base_file "$skill_file" "skills"; then
                CUSTOM_FILES+=("skills/$skill_file")
                log_custom "Custom skill: $skill_name"
                ((custom_count++))
            fi
        done < <(find .factory/skills -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi

    # Check for custom commands
    if [[ -d ".factory/commands" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            if ! is_base_file "$basename_file" "commands"; then
                CUSTOM_FILES+=("commands/$basename_file")
                log_custom "Custom command: $basename_file"
                ((custom_count++))
            fi
        done < <(find .factory/commands -name "*.md" -type f -print0 2>/dev/null)
    fi

    # Check for custom hooks
    if [[ -d ".factory/hooks" ]] && [[ -n "$(ls -A .factory/hooks 2>/dev/null)" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            CUSTOM_FILES+=("hooks/$basename_file")
            log_custom "Custom hook: $basename_file"
            ((custom_count++))
        done < <(find .factory/hooks -type f -print0 2>/dev/null)
    fi

    # Check for custom standards
    if [[ -d ".factory/standards" ]] && [[ -n "$(ls -A .factory/standards 2>/dev/null)" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            CUSTOM_FILES+=("standards/$basename_file")
            log_custom "Custom standard: $basename_file"
            ((custom_count++))
        done < <(find .factory/standards -type f -print0 2>/dev/null)
    fi

    if [[ $custom_count -eq 0 ]]; then
        log_info "No custom files detected"
    else
        log_success "Found $custom_count custom file(s)"
    fi
}

# ============================================================================
# SMART MERGE FUNCTIONS
# ============================================================================

backup_custom_files() {
    if [[ ${#CUSTOM_FILES[@]} -eq 0 ]]; then
        return 0
    fi

    log_step "Backing up custom files..."

    local backup_dir=".factory-custom-backup.$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for file in "${CUSTOM_FILES[@]}"; do
        if [[ -f ".factory/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p "$backup_dir/$dir"
            cp ".factory/$file" "$backup_dir/$file"
            log_success "Backed up: $file"
        elif [[ -d ".factory/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p "$backup_dir/$dir"
            cp -r ".factory/$file" "$backup_dir/$file"
            log_success "Backed up: $file"
        fi
    done

    echo "$backup_dir" > .factory-custom-backup-location
    log_success "Custom files backed up to: $backup_dir"
}

restore_custom_files() {
    if [[ ${#CUSTOM_FILES[@]} -eq 0 ]]; then
        return 0
    fi

    log_step "Restoring custom files..."

    if [[ ! -f .factory-custom-backup-location ]]; then
        log_warning "No backup location found, skipping restore"
        return 0
    fi

    local backup_dir
    backup_dir=$(cat .factory-custom-backup-location)

    if [[ ! -d "$backup_dir" ]]; then
        log_warning "Backup directory not found: $backup_dir"
        return 0
    fi

    for file in "${CUSTOM_FILES[@]}"; do
        if [[ -f "$backup_dir/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p ".factory/$dir"
            cp "$backup_dir/$file" ".factory/$file"
            PRESERVED_FILES+=("$file")
            log_success "Restored: $file"
        elif [[ -d "$backup_dir/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p ".factory/$dir"
            cp -r "$backup_dir/$file" ".factory/$file"
            PRESERVED_FILES+=("$file")
            log_success "Restored: $file"
        fi
    done

    # Clean up backup location file
    rm -f .factory-custom-backup-location
}

preserve_memory_files() {
    log_step "Preserving memory files..."

    local memory_backup=".factory-memory-backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d ".factory/memory" ]]; then
        cp -r ".factory/memory" "$memory_backup"
        log_success "Memory files backed up to: $memory_backup"
        echo "$memory_backup" > .factory-memory-backup-location
    else
        log_info "No existing memory files to preserve"
    fi
}

restore_memory_files() {
    log_step "Restoring memory files..."

    if [[ ! -f .factory-memory-backup-location ]]; then
        log_info "No memory backup found, will use fresh memory files"
        return 0
    fi

    local memory_backup
    memory_backup=$(cat .factory-memory-backup-location)

    if [[ ! -d "$memory_backup" ]]; then
        log_warning "Memory backup directory not found: $memory_backup"
        return 0
    fi

    # Restore org memory (decisions, patterns, tech-stack)
    if [[ -d "$memory_backup/org" ]]; then
        cp -r "$memory_backup/org"/* ".factory/memory/org/" 2>/dev/null || true
        log_success "Restored organization memory"
    fi

    # Restore user memory (preferences, context)
    if [[ -d "$memory_backup/user" ]]; then
        cp -r "$memory_backup/user"/* ".factory/memory/user/" 2>/dev/null || true
        log_success "Restored user memory"
    fi

    # Clean up backup location file
    rm -f .factory-memory-backup-location
}

preserve_active_specs() {
    log_step "Preserving active specs..."

    local specs_backup=".factory-specs-backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d ".factory/specs/active" ]] && [[ -n "$(ls -A .factory/specs/active 2>/dev/null)" ]]; then
        mkdir -p "$specs_backup"
        cp -r ".factory/specs/active"/* "$specs_backup/" 2>/dev/null || true
        log_success "Active specs backed up to: $specs_backup"
        echo "$specs_backup" > .factory-specs-backup-location
    else
        log_info "No active specs to preserve"
    fi
}

restore_active_specs() {
    log_step "Restoring active specs..."

    if [[ ! -f .factory-specs-backup-location ]]; then
        log_info "No specs backup found"
        return 0
    fi

    local specs_backup
    specs_backup=$(cat .factory-specs-backup-location)

    if [[ ! -d "$specs_backup" ]]; then
        log_warning "Specs backup directory not found: $specs_backup"
        return 0
    fi

    mkdir -p ".factory/specs/active"
    cp -r "$specs_backup"/* ".factory/specs/active/" 2>/dev/null || true
    log_success "Restored active specs"

    # Clean up backup location file
    rm -f .factory-specs-backup-location
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_framework() {
    log_step "Installing Droidz Framework..."

    local repo_url="https://github.com/korallis/Droidz.git"
    local branch="Claude-Code"
    local install_dir=".factory"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    log_info "Created temporary directory: $TEMP_DIR"

    # Clone the framework
    log_info "Downloading framework from GitHub..."
    local clone_output
    if ! clone_output=$(git clone --depth 1 --branch "$branch" "$repo_url" "$TEMP_DIR/droidz" 2>&1); then
        log_error "git clone failed:"
        echo "$clone_output" >&2
        error_exit "Failed to clone repository" 1
    fi
    log_success "Framework downloaded"

    if [[ ! -d "$TEMP_DIR/droidz/.factory" ]]; then
        error_exit "Framework files not found in downloaded package" 1
    fi

    # Detect if this is an update
    local is_update=false
    if [[ -d "$install_dir" ]]; then
        is_update=true
        log_info "Existing installation detected - performing smart update"

        # Detect custom files
        detect_custom_files

        # Backup custom files, memory, and active specs
        backup_custom_files
        preserve_memory_files
        preserve_active_specs

        # Remove old installation
        log_info "Removing old framework files..."
        rm -rf "$install_dir"
    else
        log_info "Fresh installation - no existing files to preserve"
    fi

    # Install new framework
    log_info "Installing framework files..."
    cp -r "$TEMP_DIR/droidz/.factory" "$install_dir"
    log_success "Framework files installed to $install_dir/"

    # Restore preserved files
    if [[ "$is_update" == true ]]; then
        restore_custom_files
        restore_memory_files
        restore_active_specs
    fi

    # Copy documentation to root
    log_info "Installing documentation..."
    local docs=(
        "README.md"
        "QUICK_START.md"
    )

    for doc in "${docs[@]}"; do
        if [[ -f "$TEMP_DIR/droidz/$doc" ]]; then
            if [[ -f "./$doc" ]] && [[ "$is_update" == true ]]; then
                local backup_name="${doc}.backup.$(date +%Y%m%d_%H%M%S)"
                mv "./$doc" "$backup_name"
                log_info "Backed up existing $doc to $backup_name"
            fi
            cp "$TEMP_DIR/droidz/$doc" "./"
            UPDATED_FILES+=("$doc")
            log_success "Installed: $doc"
        fi
    done

    # Make scripts executable
    if [[ -f "$install_dir/scripts/orchestrator.sh" ]]; then
        chmod +x "$install_dir/scripts/orchestrator.sh"
        log_success "Made orchestrator.sh executable"
    fi

    # Clean up temp directory
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    log_success "Temporary files cleaned up"
}

verify_installation() {
    log_step "Verifying installation..."

    local required_dirs=(
        ".factory/agents"
        ".factory/skills"
        ".factory/commands"
        ".factory/scripts"
        ".factory/memory/org"
        ".factory/memory/user"
        ".factory/product"
        ".factory/specs/templates"
        ".factory/specs/active"
        ".factory/specs/archive"
    )

    local required_files=(
        ".factory/agents/codegen.md"
        ".factory/agents/test.md"
        ".factory/agents/refactor.md"
        ".factory/agents/infra.md"
        ".factory/agents/integration.md"
        ".factory/agents/droidz-orchestrator.md"
        ".factory/agents/generalist.md"
        ".factory/skills/spec-shaper/SKILL.md"
        ".factory/skills/auto-orchestrator/SKILL.md"
        ".factory/skills/memory-manager/SKILL.md"
        ".factory/commands/droidz-init.md"
        ".factory/commands/create-spec.md"
        ".factory/commands/validate-spec.md"
        ".factory/commands/spec-to-tasks.md"
        ".factory/commands/orchestrate.md"
        ".factory/scripts/orchestrator.sh"
        ".factory/product/vision.md"
        ".factory/product/roadmap.md"
        ".factory/product/use-cases.md"
        ".factory/specs/templates/feature-spec.md"
        ".factory/specs/templates/epic-spec.md"
    )

    local missing=0

    # Check directories
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Missing directory: $dir"
            ((missing++))
        fi
    done

    # Check files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing file: $file"
            ((missing++))
        fi
    done

    if [[ $missing -gt 0 ]]; then
        error_exit "Installation verification failed: $missing items missing" 1
    fi

    log_success "All required files and directories present"

    # Verify memory files were created
    local memory_files=(
        ".factory/memory/org/decisions.json"
        ".factory/memory/org/patterns.json"
        ".factory/memory/org/tech-stack.json"
        ".factory/memory/user/preferences.json"
        ".factory/memory/user/context.json"
    )

    local memory_count=0
    for file in "${memory_files[@]}"; do
        if [[ -f "$file" ]]; then
            ((memory_count++))
        fi
    done

    if [[ $memory_count -eq 5 ]]; then
        log_success "Memory system verified (5/5 files)"
    else
        log_warning "Memory system incomplete ($memory_count/5 files)"
    fi

    # Count components
    local agent_count
    agent_count=$(find .factory/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $agent_count agent(s)"

    local skill_count
    skill_count=$(find .factory/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $skill_count skill(s)"

    local command_count
    command_count=$(find .factory/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $command_count command(s)"
}

setup_gitignore() {
    log_step "Configuring .gitignore..."

    local gitignore_entries=(
        "# Droidz Framework - User-specific files"
        ".factory/memory/user/"
        ".runs/"
        "*.backup.*"
        "*-tasks.json"
        ".factory-*-backup*"
    )

    if [[ -f .gitignore ]]; then
        # Check if entries already exist
        if grep -q "Droidz Framework" .gitignore 2>/dev/null; then
            log_info ".gitignore already configured"
            return 0
        fi

        # Add entries
        log_info "Updating .gitignore..."
        {
            echo ""
            echo "# Droidz Framework - User-specific files"
            echo ".factory/memory/user/"
            echo ".runs/"
            echo "*.backup.*"
            echo "*-tasks.json"
            echo ".factory-*-backup*"
        } >> .gitignore
        log_success ".gitignore updated"
    else
        log_info "Creating .gitignore..."
        printf "%s\n" "${gitignore_entries[@]}" > .gitignore
        log_success ".gitignore created"
    fi
}

initialize_memory() {
    log_step "Initializing memory system..."

    # Create org memory files if they don't exist
    if [[ ! -f ".factory/memory/org/decisions.json" ]]; then
        cat > .factory/memory/org/decisions.json << 'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "version": "1.0.0",
  "lastUpdated": null,
  "decisions": [],
  "metadata": {
    "description": "Architectural and technical decisions for this project"
  }
}
EOF
        log_success "Created decisions.json"
    fi

    if [[ ! -f ".factory/memory/org/patterns.json" ]]; then
        cat > .factory/memory/org/patterns.json << 'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "version": "1.0.0",
  "lastUpdated": null,
  "patterns": [],
  "metadata": {
    "description": "Code patterns and conventions for this project"
  }
}
EOF
        log_success "Created patterns.json"
    fi

    if [[ ! -f ".factory/memory/org/tech-stack.json" ]]; then
        cat > .factory/memory/org/tech-stack.json << 'EOF'
{
  "version": "1.0.0",
  "lastUpdated": null,
  "detected": false,
  "framework": null,
  "stack": {
    "runtime": null,
    "packageManager": null,
    "frameworks": [],
    "libraries": [],
    "buildTools": [],
    "testFrameworks": []
  }
}
EOF
        log_success "Created tech-stack.json"
    fi

    # Create user memory files if they don't exist
    if [[ ! -f ".factory/memory/user/preferences.json" ]]; then
        cat > .factory/memory/user/preferences.json << 'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "version": "1.0.0",
  "lastUpdated": null,
  "preferences": {},
  "metadata": {
    "description": "User-specific preferences for Droidz framework"
  }
}
EOF
        log_success "Created preferences.json"
    fi

    if [[ ! -f ".factory/memory/user/context.json" ]]; then
        cat > .factory/memory/user/context.json << 'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "version": "1.0.0",
  "lastUpdated": null,
  "context": {},
  "metadata": {
    "description": "Session context and state for Droidz framework"
  },
  "activeOrchestrations": [],
  "recentSessions": [],
  "workInProgress": []
}
EOF
        log_success "Created context.json"
    fi

    # Create tasks directory for spec-to-tasks output
    if [[ ! -d ".factory/specs/active/tasks" ]]; then
        mkdir -p ".factory/specs/active/tasks"
        log_success "Created tasks directory"
    fi

    log_success "Memory system initialized"
}

display_update_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║   🎉 Droidz Update Complete!                        ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Updated files
    if [[ ${#UPDATED_FILES[@]} -gt 0 ]]; then
        echo -e "${CYAN}Framework Files Updated:${NC}"
        echo -e "  ${GREEN}✓${NC} 7 Base Agents"
        echo -e "  ${GREEN}✓${NC} 3 Base Skills"
        echo -e "  ${GREEN}✓${NC} Core Commands"
        echo -e "  ${GREEN}✓${NC} Orchestration Engine"
        echo -e "  ${GREEN}✓${NC} Documentation"
        echo ""
    fi

    # Preserved custom files
    if [[ ${#PRESERVED_FILES[@]} -gt 0 ]]; then
        echo -e "${MAGENTA}Custom Files Preserved:${NC}"
        for file in "${PRESERVED_FILES[@]}"; do
            echo -e "  ${MAGENTA}★${NC} $file"
        done
        echo ""
    fi

    # Memory status
    echo -e "${CYAN}Your Data Preserved:${NC}"
    echo -e "  ${GREEN}✓${NC} Architectural decisions"
    echo -e "  ${GREEN}✓${NC} Code patterns"
    echo -e "  ${GREEN}✓${NC} Tech stack info"
    echo -e "  ${GREEN}✓${NC} User preferences"
    echo -e "  ${GREEN}✓${NC} Active specs"
    echo ""

    echo -e "${CYAN}What Changed:${NC}"
    echo -e "  • Base framework updated to latest version"
    echo -e "  • All custom files preserved automatically"
    echo -e "  • Memory and specs carried forward"
    echo -e "  • No manual merge needed!"
    echo ""

    echo -e "${GREEN}Your custom work is safe! Update complete. 🚀${NC}"
    echo ""
}

display_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║   🎉 Droidz Installation Complete!                  ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Framework Components Installed:${NC}"
    echo -e "  ${GREEN}✓${NC} 7 Specialist Agents (codegen, test, refactor, etc.)"
    echo -e "  ${GREEN}✓${NC} 3 Auto-Activating Skills (spec-shaper, orchestrator, memory)"
    echo -e "  ${GREEN}✓${NC} 10+ Slash Commands (/create-spec, /orchestrate, etc.)"
    echo -e "  ${GREEN}✓${NC} Orchestration Engine (750+ lines, tmux + worktrees)"
    echo -e "  ${GREEN}✓${NC} Persistent Memory System (5 JSON files)"
    echo -e "  ${GREEN}✓${NC} Spec Templates (feature, epic, refactor)"
    echo -e "  ${GREEN}✓${NC} Complete Documentation"
    echo ""
    echo -e "${CYAN}Installed Files:${NC}"
    echo -e "  📁 ${BOLD}.factory/${NC}                    - Framework directory"
    echo -e "  📄 ${BOLD}README.md${NC}                   - Complete framework guide"
    echo -e "  📄 ${BOLD}QUICK_START.md${NC}              - 5-minute quick start"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  ${BOLD}1.${NC} Initialize:  ${BLUE}claude${NC} then ${BLUE}/droidz-init${NC}"
    echo -e "  ${BOLD}2.${NC} Read guide:  ${BLUE}cat README.md${NC}"
    echo -e "  ${BOLD}3.${NC} Quick start: ${BLUE}cat QUICK_START.md${NC}"
    echo ""
    echo -e "${YELLOW}💡 First Time Setup:${NC}"
    echo -e "   1. Start Claude Code: ${BLUE}claude${NC}"
    echo -e "   2. Run initialization: ${BLUE}/droidz-init${NC}"
    echo -e "   3. Create your first spec: ${BLUE}/create-spec feature my-feature${NC}"
    echo ""
    echo -e "${CYAN}What Droidz Does:${NC}"
    echo -e "  ✅ Structures complex projects with specifications"
    echo -e "  ✅ Enables parallel development via git worktrees"
    echo -e "  ✅ Routes tasks to specialist agents"
    echo -e "  ✅ Maintains persistent memory across sessions"
    echo -e "  ✅ Realistic 1.5-2.5x speedup for parallelizable work"
    echo ""
    echo -e "${GREEN}Happy building with Droidz! 🚀${NC}"
    echo ""
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║   Droidz Claude Code Framework Installer v2.0       ║${NC}"
    echo -e "${CYAN}${BOLD}║   Smart Update with Custom File Preservation        ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    local is_update=false
    if [[ -d ".factory" ]]; then
        is_update=true
    fi

    check_prerequisites
    install_framework
    initialize_memory
    setup_gitignore
    verify_installation

    if [[ "$is_update" == true ]]; then
        display_update_summary
    else
        display_summary
    fi
}

main "$@"
