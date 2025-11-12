#!/usr/bin/env bash
#
# Droidz Claude Code Framework - One-Line Installer
#
# Install with:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh
#   chmod +x install-claude-code.sh
#   ./install-claude-code.sh
#
# Version: 1.0.0
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
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
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
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_step() {
    echo -e "\n${CYAN}${BOLD}▸ $*${NC}"
}

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
    fi
}

trap cleanup EXIT
trap 'log_error "Installation interrupted by user"; exit 130' INT TERM

error_exit() {
    log_error "$1"
    exit "${2:-1}"
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
        PKG_MANAGER="apt"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        PKG_MANAGER="apt"
    else
        OS="unknown"
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
        *)
            echo "Please install $package manually"
            ;;
    esac
}

check_prerequisites() {
    log_step "Checking prerequisites..."

    # Initialize missing dependencies array
    MISSING_DEPS=()

    # Detect operating system
    detect_os
    log_info "Detected OS: $OS (Package manager: $PKG_MANAGER)"

    # Check for git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed."
        log_info "Install with: $(get_install_cmd git)"
        error_exit "Git is required." 1
    fi
    log_success "Git found: $(git --version | head -n1)"

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
        error_exit "Not in a git repository. Please run this script from your project root." 1
    fi
    log_success "Git repository detected"

    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        log_error "Neither curl nor wget found."
        log_info "Install with: $(get_install_cmd curl)"
        error_exit "curl or wget is required." 1
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
        log_info "Install with: $(get_install_cmd jq)"
        MISSING_DEPS+=("jq")
    else
        log_success "jq found"
    fi

    # Check for tmux (required for parallel execution)
    if ! command -v tmux &> /dev/null; then
        log_warning "tmux not found. Required for parallel task monitoring."
        log_info "Install with: $(get_install_cmd tmux)"
        MISSING_DEPS+=("tmux")
    else
        log_success "tmux found"
    fi

    # Summary of missing dependencies
    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        echo ""
        log_warning "Missing optional dependencies: ${MISSING_DEPS[*]}"
        log_info "Droidz will install, but orchestration features require jq and tmux."

        if [[ "$PKG_MANAGER" == "apt" ]]; then
            log_info "Install all at once: sudo apt update && sudo apt install -y jq tmux"
        elif [[ "$PKG_MANAGER" == "brew" ]]; then
            log_info "Install all at once: brew install jq tmux"
        fi
        echo ""
    fi
}

# ============================================================================
# BACKUP FUNCTIONS
# ============================================================================

backup_existing() {
    local target="$1"

    if [[ -e "$target" ]]; then
        local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing ${target} to ${backup_name}"
        mv "$target" "$backup_name"
        log_success "Backup created: ${backup_name}"
        return 0
    fi
    return 1
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_framework() {
    log_step "Installing Droidz Framework..."

    local repo_url="https://github.com/korallis/Droidz.git"
    local branch="Claude-Code"
    local install_dir=".claude"

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

    # Backup existing .claude directory if it exists
    if [[ -d "$install_dir" ]]; then
        log_warning "Existing $install_dir directory found"
        backup_existing "$install_dir"
    fi

    # Copy framework files
    log_info "Installing framework files..."

    if [[ ! -d "$TEMP_DIR/droidz/.claude" ]]; then
        error_exit "Framework files not found in downloaded package" 1
    fi

    cp -r "$TEMP_DIR/droidz/.claude" "$install_dir"
    log_success "Framework files installed to $install_dir/"

    # Copy documentation to root
    log_info "Installing documentation..."
    local docs=(
        "README.md"
        "QUICK_START.md"
    )

    for doc in "${docs[@]}"; do
        if [[ -f "$TEMP_DIR/droidz/$doc" ]]; then
            if [[ -f "./$doc" ]]; then
                backup_existing "./$doc"
            fi
            cp "$TEMP_DIR/droidz/$doc" "./"
            log_success "Installed: $doc"
        fi
    done

    # Copy orchestrator script
    if [[ -f "$TEMP_DIR/droidz/.claude/scripts/orchestrator.sh" ]]; then
        chmod +x "$install_dir/scripts/orchestrator.sh"
        log_success "Made orchestrator.sh executable"
    fi

    # Clean up temp directory
    log_info "Cleaning up..."
    rm -rf "$TEMP_DIR"
    log_success "Temporary files cleaned up"
}

verify_installation() {
    log_step "Verifying installation..."

    local required_dirs=(
        ".claude/agents"
        ".claude/skills"
        ".claude/commands"
        ".claude/scripts"
        ".claude/memory/org"
        ".claude/memory/user"
        ".claude/product"
        ".claude/specs/templates"
        ".claude/specs/active"
        ".claude/specs/archive"
    )

    local required_files=(
        ".claude/agents/codegen.md"
        ".claude/agents/test.md"
        ".claude/agents/refactor.md"
        ".claude/agents/infra.md"
        ".claude/agents/integration.md"
        ".claude/agents/orchestrator.md"
        ".claude/agents/generalist.md"
        ".claude/skills/spec-shaper/SKILL.md"
        ".claude/skills/auto-orchestrator/SKILL.md"
        ".claude/skills/memory-manager/SKILL.md"
        ".claude/commands/droidz-init.md"
        ".claude/commands/create-spec.md"
        ".claude/commands/validate-spec.md"
        ".claude/commands/spec-to-tasks.md"
        ".claude/commands/orchestrate.md"
        ".claude/scripts/orchestrator.sh"
        ".claude/memory/org/decisions.json"
        ".claude/memory/org/patterns.json"
        ".claude/memory/org/tech-stack.json"
        ".claude/memory/user/preferences.json"
        ".claude/memory/user/context.json"
        ".claude/product/vision.md"
        ".claude/product/roadmap.md"
        ".claude/product/use-cases.md"
        ".claude/specs/templates/feature-spec.md"
        ".claude/specs/templates/epic-spec.md"
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

    # Count components
    local agent_count
    agent_count=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $agent_count specialist agents"

    local skill_count
    skill_count=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $skill_count auto-activating skills"

    local command_count
    command_count=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $command_count slash commands"
}

setup_gitignore() {
    log_step "Configuring .gitignore..."

    local gitignore_entries=(
        "# Droidz Framework - User-specific files"
        ".claude/memory/user/"
        ".runs/"
        "*.backup.*"
        "*-tasks.json"
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
            echo ".claude/memory/user/"
            echo ".runs/"
            echo "*.backup.*"
            echo "*-tasks.json"
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

    # Memory files should already exist from repo, just verify
    local memory_files=(
        ".claude/memory/org/decisions.json"
        ".claude/memory/org/patterns.json"
        ".claude/memory/org/tech-stack.json"
        ".claude/memory/user/preferences.json"
        ".claude/memory/user/context.json"
    )

    local initialized=0
    for file in "${memory_files[@]}"; do
        if [[ -f "$file" ]]; then
            ((initialized++))
        fi
    done

    log_success "Memory system initialized ($initialized/5 files)"
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
    echo -e "  ${GREEN}✓${NC} 5 Slash Commands (/create-spec, /orchestrate, etc.)"
    echo -e "  ${GREEN}✓${NC} Orchestration Engine (750+ lines, tmux + worktrees)"
    echo -e "  ${GREEN}✓${NC} Persistent Memory System (5 JSON files)"
    echo -e "  ${GREEN}✓${NC} Spec Templates (feature, epic, refactor)"
    echo -e "  ${GREEN}✓${NC} Complete Documentation"
    echo ""
    echo -e "${CYAN}Installed Files:${NC}"
    echo -e "  📁 ${BOLD}.claude/${NC}                    - Framework directory"
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
    echo -e "${CYAN}${BOLD}║   Droidz Claude Code Framework Installer            ║${NC}"
    echo -e "${CYAN}${BOLD}║   Version 1.0.0                                      ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites
    install_framework
    verify_installation
    setup_gitignore
    initialize_memory
    display_summary
}

main "$@"
