#!/bin/bash
#
# Droidz Installer for Factory.ai
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
#
# Version: 0.5.7
# Updated: 2025-11-17
#

set -euo pipefail

VERSION="0.5.7"
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

# Robustly detect if we're inside a git repository (handles worktrees/safe-directory issues)
detect_git_repo() {
    local start_dir="${1:-$(pwd)}"

    # Fast path: ask git directly
    if git -C "$start_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        GIT_ROOT=$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null || echo "$start_dir")
        return 0
    fi

    # Fallback: walk up to find .git directory or gitfile (worktree pointer)
    local dir="$start_dir"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]] || [[ -f "$dir/.git" ]]; then
            GIT_ROOT="$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done

    return 1
}

# Main installation
main() {
    # Banner
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║   Droidz Framework Installer v${VERSION}           ║${NC}"
    echo -e "${CYAN}${BOLD}║   For Factory.ai Droid CLI                      ║${NC}"
    echo -e "${CYAN}${BOLD}║   🚀 AI-Powered Spec Generator + Parallel Exec  ║${NC}"
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
    
    # Note: jq and tmux no longer required as we use Factory.ai Task tool for orchestration
    echo ""
    
    # Check if in git repo
    GIT_ROOT=""
    if detect_git_repo "$(pwd)"; then
        log_success "Git repository detected at ${GIT_ROOT}"
    else
        log_warning "Not in a git repository (checked $(pwd) and parents)"
        echo ""

        if [[ -t 0 ]]; then
            echo -e "${YELLOW}Initialize git repository now?${NC}"
            read -p "[Y/n]: " -n 1 -r || true
            echo ""
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_error "Droidz requires a git repository"
                exit 1
            fi
            git init
            GIT_ROOT="$(pwd)"
            log_success "Git repository initialized"
        else
            log_info "Non-interactive run detected; initializing git repository automatically"
            git init
            GIT_ROOT="$(pwd)"
            log_success "Git repository initialized"
        fi
    fi
    
    # Create directory structure (only what we need)
    log_step "Creating directories"
    mkdir -p .factory/{commands,droids,scripts,hooks,skills}
    mkdir -p .droidz/specs
    log_success "Directories created"
    
    # Download framework files
    log_step "Downloading Droidz framework"
    
    # Commands
    log_info "Downloading commands..."
    
    # Markdown commands (prompts)
    download_file "$REPO_URL/.factory/commands/droidz-init.md" ".factory/commands/droidz-init.md" "droidz-init command (NEW!)"
    download_file "$REPO_URL/.factory/commands/droidz-build.md" ".factory/commands/droidz-build.md" "droidz-build command"
    download_file "$REPO_URL/.factory/commands/auto-parallel.md" ".factory/commands/auto-parallel.md" "auto-parallel command"
    download_file "$REPO_URL/.factory/commands/gh-helper.md" ".factory/commands/gh-helper.md" "gh-helper command"
    
    # Executable commands (bash scripts)
    download_file "$REPO_URL/.factory/commands/gh-helper.sh" ".factory/commands/gh-helper.sh" "gh-helper script"
    chmod +x ".factory/commands/gh-helper.sh"
    
    # Droids
    log_info "Downloading specialist droids..."
    for droid in droidz-orchestrator droidz-codegen droidz-test droidz-refactor droidz-integration droidz-infra droidz-generalist; do
        download_file "$REPO_URL/.factory/droids/${droid}.md" ".factory/droids/${droid}.md" "$droid droid"
    done
    
    # Scripts directory (currently empty, but keep structure for future use)
    mkdir -p .factory/scripts
    
    # Hooks
    log_info "Downloading skills injection hooks..."
    for hook in inject-skills inject-file-skills load-project-skills; do
        download_file "$REPO_URL/.factory/hooks/${hook}.sh" ".factory/hooks/${hook}.sh" "$hook hook"
        chmod +x ".factory/hooks/${hook}.sh"
    done
    
    # Skills (all 41 comprehensive skills)
    log_info "Downloading comprehensive skill library (41 skills)..."
    
    # Framework & Integration Skills (21)
    for skill in typescript react nextjs-16 tailwind-v4 convex prisma drizzle postgresql supabase neon clerk stripe vercel cloudflare-workers trpc tanstack-query security design context-optimizer standards-enforcer tech-stack-analyzer; do
        download_file "$REPO_URL/.factory/skills/${skill}.md" ".factory/skills/${skill}.md" "$skill skill"
    done
    
    # Workflow & Process Skills (19 - adapted from obra/superpowers)
    for skill in test-driven-development systematic-debugging verification-before-completion defense-in-depth testing-anti-patterns brainstorming writing-skills executing-plans requesting-code-review receiving-code-review root-cause-tracing subagent-driven-development finishing-a-development-branch using-git-worktrees condition-based-waiting dispatching-parallel-agents testing-skills-with-subagents sharing-skills using-droidz; do
        download_file "$REPO_URL/.factory/skills/${skill}.md" ".factory/skills/${skill}.md" "$skill skill"
    done
    
    # Meta/Guide Skills (2)
    download_file "$REPO_URL/.factory/skills/ADAPTATION_GUIDE.md" ".factory/skills/ADAPTATION_GUIDE.md" "adaptation guide"
    
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
    download_file "$REPO_URL/AGENTS.md.template" "AGENTS.md.template" "AGENTS.md template"
    download_file "$REPO_URL/.factory/HOOKS.md" ".factory/HOOKS.md" "Hooks documentation"
    download_file "$REPO_URL/.factory/SETTINGS.md" ".factory/SETTINGS.md" "Settings documentation"
    
    # Fix documentation
    mkdir -p docs/fixes
    if download_file "$REPO_URL/docs/fixes/2025-11-15-task-tool-model-parameter-fix.md" "docs/fixes/2025-11-15-task-tool-model-parameter-fix.md" "Task tool fix documentation" 2>/dev/null; then
        log_success "Task tool fix documentation downloaded"
    fi
    if download_file "$REPO_URL/docs/fixes/2025-11-15-droid-model-identifier-fix.md" "docs/fixes/2025-11-15-droid-model-identifier-fix.md" "Droid model fix documentation" 2>/dev/null; then
        log_success "Droid model fix documentation downloaded"
    fi
    
    # Quick start guide (optional, don't fail if missing)
    if download_file "$REPO_URL/QUICK_START.md" "QUICK_START.md" "Quick Start guide" 2>/dev/null; then
        log_success "Quick Start guide downloaded"
    fi
    
    # Skills summary (optional)
    if download_file "$REPO_URL/SKILLS_SUMMARY.md" "SKILLS_SUMMARY.md" "Skills summary" 2>/dev/null; then
        log_success "Skills summary downloaded"
    fi
    
    # Spec generator example
    log_info "Downloading spec generator example..."
    if download_file "$REPO_URL/.droidz/specs/000-example-contact-form.md" ".droidz/specs/000-example-contact-form.md" "example spec" 2>/dev/null; then
        log_success "Example spec downloaded"
    fi
    
    # .droidz/.gitignore
    if [[ ! -f ".droidz/.gitignore" ]]; then
        download_file "$REPO_URL/.droidz/.gitignore" ".droidz/.gitignore" ".droidz gitignore"
    fi
    
    # No legacy status script needed - use Factory.ai conversation for monitoring
    
    # Create .gitignore
    if [[ ! -f ".gitignore" ]]; then
        cat > .gitignore << 'EOF'
# Droidz runtime
.runs/

# Configuration with API keys - NEVER commit this!
config.yml

# Keep the template
!config.example.yml

# .droidz/ - Local state and specs (controlled by .droidz/.gitignore)
# Users can optionally commit specs by modifying .droidz/.gitignore
.droidz/*
!.droidz/.gitignore
!.droidz/specs/000-*.md

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
        echo "" >> .gitignore
        echo "# .droidz/ - Local state and specs" >> .gitignore
        echo ".droidz/*" >> .gitignore
        echo "!.droidz/.gitignore" >> .gitignore
        echo "!.droidz/specs/000-*.md" >> .gitignore
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
        echo "  ✅ Reliable parallel execution: no phantom tasks; Task IDs recorded before start"
        echo "  📣 Rich progress: step + next action + files changed + test results + heartbeat"
        echo "  ⏱ Stall detection: streams marked stalled after idle; blockers surfaced"
        echo "  🔒 Validation gating: failing lint/type/tests block completion with output shown"
        echo "  🛠 Git detection: handles worktrees/subdirectories before prompting to init"
        echo "  🛠 Headless ready: run with 'droid exec --auto high' for non-interactive orchestration"
        echo ""
        echo -e "${YELLOW}Try: /droidz-init  (verify & analyze)${NC}"
        echo -e "${YELLOW}Then: /droidz-build \"add authentication\"${NC}"
        echo ""
        echo -e "${CYAN}Quick Check:${NC}"
        echo -e "   ${GREEN}./status${NC} - See what's installed"
        echo ""
        echo -e "${CYAN}Try It Now:${NC}"
        echo -e "   ${GREEN}droid${NC}"
        echo -e "   ${GREEN}/auto-parallel \"your task\"${NC}"
        echo -e "   Monitor progress directly in conversation!"
        echo ""
    else
        echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}${BOLD}║   🎉 Installation Complete!                     ║${NC}"
        echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}What You Got (v${VERSION}):${NC}"
        echo ""
        echo "  🚀 /droidz-init - Smart Onboarding (NEW!)"
        echo "     - Verify installation"
        echo "     - Analyze project (greenfield/brownfield)"
        echo "     - Generate architecture docs"
        echo ""
        echo "  🚀 /droidz-build - AI-Powered Spec Generator (NEW!)"
        echo "     - Turn vague ideas into production-ready specs"
        echo "     - Security requirements (OWASP, GDPR)"
        echo "     - 80% less time writing specs"
        echo ""
        echo "  ✅ /auto-parallel - Parallel task execution (3-5x faster, no phantom tasks)"
        echo "  ✅ Rich progress: step, next action, files touched, test results, heartbeat"
        echo "  ✅ Stall detection + validation gating to prevent silent failures"
        echo "  ✅ Headless ready: use 'droid exec --auto high' for CI/non-interactive runs"
        echo "  ✅ 7 specialist droids + 41 skills with auto enforcement"
        echo "  ✅ Skills injection - Auto-loads based on project/prompts/files"
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
        echo -e "   ${GREEN}/commands${NC} → Should see: droidz-init, droidz-build, auto-parallel"
        echo ""
        echo "5. Start with onboarding:"
        echo -e "   ${GREEN}/droidz-init${NC}"
        echo -e "   Verifies setup, analyzes project, generates docs!"
        echo ""
        echo "6. Generate specs for features:"
        echo -e "   ${GREEN}/droidz-build \"add user authentication\"${NC}"
        echo -e "   Creates comprehensive spec with security, tests, edge cases!"
        echo ""
        echo "7. Execute in parallel:"
        echo -e "   ${GREEN}/auto-parallel \"your task\"${NC}"
        echo -e "   3-5x faster with live progress updates!"
        echo ""
    fi
    echo -e "${BLUE}📚 Read README.md for complete beginner-friendly guide!${NC}"
    echo -e "${BLUE}⚡ Quick reference: cat QUICK_START.md${NC}"
    echo -e "${BLUE}🎓 Skills guide: cat SKILLS.md${NC}"
    echo ""
}

# Run main function
main
