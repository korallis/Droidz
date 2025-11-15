#!/bin/bash
#
# Droidz Installer for Factory.ai
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
#
# Version: 0.0.94
# Updated: 2025-11-14
#

set -euo pipefail

VERSION="0.0.94"
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
    echo -e "${CYAN}${BOLD}║   🆕 Auto-Parallel + Live Monitoring            ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Detect if this is an upgrade
    UPGRADING=false
    if [[ -d ".factory/droids" ]] && [[ -f ".factory/droids/droidz-parallel.md" ]]; then
        UPGRADING=true
        echo -e "${YELLOW}📦 Existing Droidz installation detected${NC}"
        echo -e "${YELLOW}   Upgrading to v${VERSION}...${NC}"
        echo ""
    fi
    
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
    mkdir -p .factory/{commands,droids,scripts,hooks,skills}
    log_success "Directories created"
    
    # Download framework files
    log_step "Downloading Droidz framework"
    
    # Commands (only the 4 core commands)
    log_info "Downloading commands..."
    
    # Markdown commands (prompts)
    for cmd in parallel auto-parallel summary attach status watch gh-helper parallel-watch; do
        download_file "$REPO_URL/.factory/commands/${cmd}.md" ".factory/commands/${cmd}.md" "$cmd command"
    done
    
    # Executable commands (bash scripts)
    download_file "$REPO_URL/.factory/commands/status.sh" ".factory/commands/status.sh" "status command"
    download_file "$REPO_URL/.factory/commands/watch.sh" ".factory/commands/watch.sh" "watch command"
    download_file "$REPO_URL/.factory/commands/gh-helper.sh" ".factory/commands/gh-helper.sh" "gh-helper command"
    download_file "$REPO_URL/.factory/commands/parallel-watch.sh" ".factory/commands/parallel-watch.sh" "parallel-watch command"
    chmod +x ".factory/commands/status.sh"
    chmod +x ".factory/commands/watch.sh"
    chmod +x ".factory/commands/gh-helper.sh"
    chmod +x ".factory/commands/parallel-watch.sh"
    
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
    
    # Hooks
    log_info "Downloading skills injection hooks..."
    for hook in inject-skills inject-file-skills load-project-skills; do
        download_file "$REPO_URL/.factory/hooks/${hook}.sh" ".factory/hooks/${hook}.sh" "$hook hook"
        chmod +x ".factory/hooks/${hook}.sh"
    done
    
    # Skills
    log_info "Downloading professional skill templates..."
    for skill in typescript tailwind-4 convex security; do
        download_file "$REPO_URL/.factory/skills/${skill}.md" ".factory/skills/${skill}.md" "$skill skill"
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
    download_file "$REPO_URL/SKILLS.md" "SKILLS.md" "Skills guide"
    
    # Quick start guide (optional, don't fail if missing)
    if download_file "$REPO_URL/QUICK_START.md" "QUICK_START.md" "Quick Start guide" 2>/dev/null; then
        log_success "Quick Start guide downloaded"
    fi
    
    # Skills summary (optional)
    if download_file "$REPO_URL/SKILLS_SUMMARY.md" "SKILLS_SUMMARY.md" "Skills summary" 2>/dev/null; then
        log_success "Skills summary downloaded"
    fi
    
    # Status script
    download_file "$REPO_URL/status" "status" "status script"
    chmod +x "status"
    
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
    if [[ "$UPGRADING" = true ]]; then
        echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}${BOLD}║   ✅ Upgrade to v${VERSION} Complete!               ║${NC}"
        echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}🆕 What's New in v${VERSION}:${NC}"
        echo ""
        echo "  ✅ Skills Injection System - Auto-enforce coding standards!"
        echo "  ✅ 4 Professional Skills - TypeScript, Tailwind 4, Convex, Security"
        echo "  ✅ 3 Smart Hooks - Inject skills based on prompts, files, and project"
        echo "  ✅ SKILLS.md Guide - Complete documentation for creating custom skills"
        echo "  ✅ Auto-Detection - Skills load automatically when relevant"
        echo ""
        echo -e "${CYAN}Quick Check:${NC}"
        echo -e "   ${GREEN}./status${NC} - See what's installed"
        echo ""
        echo -e "${CYAN}Try It Now:${NC}"
        echo -e "   ${GREEN}droid${NC}"
        echo -e "   ${GREEN}/auto-parallel \"your task\"${NC}"
        echo -e "   ${GREEN}/watch${NC} - Live monitoring!"
        echo ""
    else
        echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}${BOLD}║   🎉 Installation Complete!                     ║${NC}"
        echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}What You Got (v${VERSION}):${NC}"
        echo ""
        echo "  ✅ Parallel orchestration that actually works"
        echo "  ✅ Live monitoring with progress bars"
        echo "  ✅ 8 specialist droids for different tasks"
        echo "  ✅ Skills injection - Auto-enforce coding standards"
        echo "  ✅ 4 professional skill templates (TypeScript, Tailwind, Convex, Security)"
        echo "  ✅ GitHub helpers and status tools"
        echo ""
        echo -e "${CYAN}Next Steps:${NC}"
        echo ""
        echo "1. Check installation:"
        echo -e "   ${GREEN}./status${NC}"
        echo ""
        echo "2. Start droid:"
        echo -e "   ${GREEN}droid${NC}"
        echo ""
        echo "3. Enable custom features:"
        echo -e "   ${GREEN}/settings${NC} → Toggle 'Custom Commands' and 'Custom Droids' ON"
        echo -e "   Exit (Ctrl+C) then run ${GREEN}droid${NC} again"
        echo ""
        echo "4. Verify commands loaded:"
        echo -e "   ${GREEN}/commands${NC} → Should see: auto-parallel, watch, gh-helper, etc."
        echo ""
        echo "5. Start using it:"
        echo -e "   ${GREEN}/auto-parallel \"your task description\"${NC}"
        echo -e "   ${GREEN}/watch${NC} → See live progress!"
        echo ""
        echo "6. Skills work automatically:"
        echo -e "   Try: ${GREEN}\"Create a TypeScript component\"${NC}"
        echo -e "   Skills auto-inject coding standards!"
        echo ""
    fi
    echo -e "${BLUE}📚 Read README.md for complete beginner-friendly guide!${NC}"
    echo -e "${BLUE}⚡ Quick reference: cat QUICK_START.md${NC}"
    echo -e "${BLUE}🎓 Skills guide: cat SKILLS.md${NC}"
    echo ""
}

# Run main function
main
