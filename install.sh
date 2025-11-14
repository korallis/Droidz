#!/bin/bash
#
# Droidz Installer for Factory.ai
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
#
# Version: 0.0.6
# Updated: 2025-11-14
#

set -euo pipefail

VERSION="0.0.6"
REPO_URL="https://raw.githubusercontent.com/korallis/Droidz/factory-ai"

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# Helper functions
log_info() { echo -e "${BLUE}ℹ${NC} $*"; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step() { echo -e "\n${CYAN}${BOLD}▸ $*${NC}"; }

# Detect OS and package manager
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command -v apt-get &> /dev/null; then
            PKG_MANAGER="apt"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
        else
            PKG_MANAGER="unknown"
        fi
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

# Get install command for a package
get_install_cmd() {
    local package="$1"
    case "$PKG_MANAGER" in
        brew) echo "brew install $package" ;;
        apt) echo "sudo apt update && sudo apt install -y $package" ;;
        dnf) echo "sudo dnf install -y $package" ;;
        yum) echo "sudo yum install -y $package" ;;
        pacman) echo "sudo pacman -S --noconfirm $package" ;;
        *) echo "Please install $package manually" ;;
    esac
}

# Check and optionally install a dependency
check_dependency() {
    local cmd="$1"
    local name="$2"
    local package="${3:-$1}"
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$name found"
        return 0
    fi
    
    log_warning "$name not found"
    
    if [[ "$PKG_MANAGER" == "unknown" ]]; then
        log_error "Cannot auto-install. Please install manually: $name"
        return 1
    fi
    
    echo -e "${YELLOW}Install $name now?${NC}"
    echo -e "  Command: $(get_install_cmd "$package")"
    read -p "Install? [y/N]: " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "$name is required but not installed"
        return 1
    fi
    
    log_info "Installing $name..."
    case "$PKG_MANAGER" in
        brew)
            brew install "$package" || return 1
            ;;
        apt)
            sudo apt-get update && sudo apt-get install -y "$package" || return 1
            ;;
        dnf)
            sudo dnf install -y "$package" || return 1
            ;;
        yum)
            sudo yum install -y "$package" || return 1
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package" || return 1
            ;;
    esac
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$name installed"
        return 0
    else
        log_error "Installation failed"
        return 1
    fi
}

# Download a file with error checking
download_file() {
    local url="$1"
    local dest="$2"
    local desc="${3:-file}"
    
    if curl -fsSL "$url" -o "$dest"; then
        log_success "Downloaded $desc"
        return 0
    else
        log_error "Failed to download $desc"
        return 1
    fi
}

# Main installation
main() {
    # Banner
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║   Droidz Framework Installer v${VERSION}           ║${NC}"
    echo -e "${CYAN}${BOLD}║   For Factory.ai Droid CLI                      ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Detect OS
    detect_os
    log_info "Detected: $OS (package manager: $PKG_MANAGER)"
    echo ""
    
    # Check dependencies
    log_step "Checking dependencies"
    
    # Git (required)
    if ! check_dependency "git" "Git"; then
        echo ""
        echo -e "${RED}Git is required. Please install it first:${NC}"
        echo -e "  $(get_install_cmd git)"
        exit 1
    fi
    
    # jq (required for orchestration)
    if ! check_dependency "jq" "jq (JSON processor)"; then
        echo ""
        log_warning "jq is required for orchestration to work"
        log_info "Install manually: $(get_install_cmd jq)"
        echo ""
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo ""
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
    
    # tmux (required for session management)
    if ! check_dependency "tmux" "tmux (session manager)"; then
        echo ""
        log_warning "tmux is required for orchestration sessions"
        log_info "Install manually: $(get_install_cmd tmux)"
        echo ""
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo ""
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
    
    echo ""
    
    # Check if in git repo
    if [[ ! -d ".git" ]]; then
        log_warning "Not in a git repository"
        echo ""
        echo -e "${YELLOW}Initialize git repository now?${NC}"
        read -p "[Y/n]: " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            git init
            log_success "Git repository initialized"
        else
            log_error "Droidz requires a git repository"
            exit 1
        fi
    fi
    
    # Create directory structure (only what we need)
    log_step "Creating directories"
    mkdir -p .factory/{commands,droids,scripts}
    log_success "Directories created"
    
    # Download framework files
    log_step "Downloading Droidz framework"
    
    # Commands (only the 5 core commands)
    log_info "Downloading commands..."
    for cmd in parallel status summary attach orchestrate; do
        download_file "$REPO_URL/.factory/commands/${cmd}.md" ".factory/commands/${cmd}.md" "$cmd command"
    done
    
    # Droids
    log_info "Downloading helper droids..."
    for droid in droidz-parallel droidz-orchestrator codegen test refactor integration infra generalist; do
        download_file "$REPO_URL/.factory/droids/${droid}.md" ".factory/droids/${droid}.md" "$droid droid"
    done
    
    # Scripts
    log_info "Downloading orchestration scripts..."
    for script in orchestrator dependency-resolver parallel-executor; do
        download_file "$REPO_URL/.factory/scripts/${script}.sh" ".factory/scripts/${script}.sh" "$script script"
        chmod +x ".factory/scripts/${script}.sh"
    done
    
    # Configuration
    log_info "Downloading configuration..."
    download_file "$REPO_URL/config.example.yml" "config.example.yml" "config template"
    
    if [[ ! -f "config.yml" ]]; then
        cp config.example.yml config.yml
        log_success "Created config.yml"
    else
        log_info "config.yml exists - keeping your settings"
    fi
    
    # Settings
    if [[ ! -f ".factory/settings.json" ]]; then
        download_file "$REPO_URL/.factory/settings.json" ".factory/settings.json" "settings"
    else
        log_info "settings.json exists - keeping your settings"
    fi
    
    # Documentation
    log_info "Downloading documentation..."
    download_file "$REPO_URL/README.md" "README.md" "README"
    
    # Create .gitignore
    if [[ ! -f ".gitignore" ]]; then
        cat > .gitignore << 'EOF'
# Droidz runtime
.runs/

# Configuration with API keys - NEVER commit this!
config.yml

# Keep the template
!config.example.yml

# Dependencies
node_modules/
bun.lockb

# Common ignores
.DS_Store
*.log
EOF
        log_success "Created .gitignore"
    elif ! grep -q "config.yml" .gitignore; then
        echo "" >> .gitignore
        echo "# Droidz configuration - NEVER commit this!" >> .gitignore
        echo "config.yml" >> .gitignore
        log_success "Updated .gitignore"
    fi
    
    # Success message
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║   🎉 Installation Complete!                     ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo "1. Start droid:"
    echo -e "   ${GREEN}droid${NC}"
    echo ""
    echo "2. Enable custom droids:"
    echo -e "   ${GREEN}/settings${NC} → Toggle 'Custom Droids' ON"
    echo ""
    echo "3. Restart droid:"
    echo -e "   Exit (Ctrl+C) then run ${GREEN}droid${NC} again"
    echo ""
    echo "4. Verify installation:"
    echo -e "   ${GREEN}/droids${NC} → Should see droidz-parallel, etc."
    echo ""
    echo "5. Start using it:"
    echo -e "   ${GREEN}/parallel \"your task description\"${NC}"
    echo ""
    echo -e "${BLUE}Read README.md for complete beginner-friendly guide!${NC}"
    echo ""
}

# Run main function
main
