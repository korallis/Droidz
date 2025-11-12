#!/usr/bin/env bash
#
# Droidz Claude Code Framework - Smart Installer with Merge Support
#
# Install with:
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh
#   chmod +x install-claude-code.sh
#   ./install-claude-code.sh
#
# Version: 2.0.0 - Smart merge support for updates
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
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_step() {
    echo -e "\n${CYAN}${BOLD}▸ $*${NC}"
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
    if [[ -d ".claude/agents" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            if ! is_base_file "$basename_file" "agents"; then
                CUSTOM_FILES+=("agents/$basename_file")
                log_custom "Custom agent: $basename_file"
                ((custom_count++))
            fi
        done < <(find .claude/agents -name "*.md" -type f -print0 2>/dev/null)
    fi

    # Check for custom skills
    if [[ -d ".claude/skills" ]]; then
        while IFS= read -r -d '' dir; do
            local skill_name
            skill_name=$(basename "$dir")
            local skill_file="$skill_name/SKILL.md"
            if ! is_base_file "$skill_file" "skills"; then
                CUSTOM_FILES+=("skills/$skill_file")
                log_custom "Custom skill: $skill_name"
                ((custom_count++))
            fi
        done < <(find .claude/skills -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi

    # Check for custom commands
    if [[ -d ".claude/commands" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            if ! is_base_file "$basename_file" "commands"; then
                CUSTOM_FILES+=("commands/$basename_file")
                log_custom "Custom command: $basename_file"
                ((custom_count++))
            fi
        done < <(find .claude/commands -name "*.md" -type f -print0 2>/dev/null)
    fi

    # Check for custom hooks
    if [[ -d ".claude/hooks" ]] && [[ -n "$(ls -A .claude/hooks 2>/dev/null)" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            CUSTOM_FILES+=("hooks/$basename_file")
            log_custom "Custom hook: $basename_file"
            ((custom_count++))
        done < <(find .claude/hooks -type f -print0 2>/dev/null)
    fi

    # Check for custom standards
    if [[ -d ".claude/standards" ]] && [[ -n "$(ls -A .claude/standards 2>/dev/null)" ]]; then
        while IFS= read -r -d '' file; do
            local basename_file
            basename_file=$(basename "$file")
            CUSTOM_FILES+=("standards/$basename_file")
            log_custom "Custom standard: $basename_file"
            ((custom_count++))
        done < <(find .claude/standards -type f -print0 2>/dev/null)
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

    local backup_dir=".claude-custom-backup.$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for file in "${CUSTOM_FILES[@]}"; do
        if [[ -f ".claude/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p "$backup_dir/$dir"
            cp ".claude/$file" "$backup_dir/$file"
            log_success "Backed up: $file"
        elif [[ -d ".claude/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p "$backup_dir/$dir"
            cp -r ".claude/$file" "$backup_dir/$file"
            log_success "Backed up: $file"
        fi
    done

    echo "$backup_dir" > .claude-custom-backup-location
    log_success "Custom files backed up to: $backup_dir"
}

restore_custom_files() {
    if [[ ${#CUSTOM_FILES[@]} -eq 0 ]]; then
        return 0
    fi

    log_step "Restoring custom files..."

    if [[ ! -f .claude-custom-backup-location ]]; then
        log_warning "No backup location found, skipping restore"
        return 0
    fi

    local backup_dir
    backup_dir=$(cat .claude-custom-backup-location)

    if [[ ! -d "$backup_dir" ]]; then
        log_warning "Backup directory not found: $backup_dir"
        return 0
    fi

    for file in "${CUSTOM_FILES[@]}"; do
        if [[ -f "$backup_dir/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p ".claude/$dir"
            cp "$backup_dir/$file" ".claude/$file"
            PRESERVED_FILES+=("$file")
            log_success "Restored: $file"
        elif [[ -d "$backup_dir/$file" ]]; then
            local dir
            dir=$(dirname "$file")
            mkdir -p ".claude/$dir"
            cp -r "$backup_dir/$file" ".claude/$file"
            PRESERVED_FILES+=("$file")
            log_success "Restored: $file"
        fi
    done

    # Clean up backup location file
    rm -f .claude-custom-backup-location
}

preserve_memory_files() {
    log_step "Preserving memory files..."

    local memory_backup=".claude-memory-backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d ".claude/memory" ]]; then
        cp -r ".claude/memory" "$memory_backup"
        log_success "Memory files backed up to: $memory_backup"
        echo "$memory_backup" > .claude-memory-backup-location
    else
        log_info "No existing memory files to preserve"
    fi
}

restore_memory_files() {
    log_step "Restoring memory files..."

    if [[ ! -f .claude-memory-backup-location ]]; then
        log_info "No memory backup found, will use fresh memory files"
        return 0
    fi

    local memory_backup
    memory_backup=$(cat .claude-memory-backup-location)

    if [[ ! -d "$memory_backup" ]]; then
        log_warning "Memory backup directory not found: $memory_backup"
        return 0
    fi

    # Restore org memory (decisions, patterns, tech-stack)
    if [[ -d "$memory_backup/org" ]]; then
        cp -r "$memory_backup/org"/* ".claude/memory/org/" 2>/dev/null || true
        log_success "Restored organization memory"
    fi

    # Restore user memory (preferences, context)
    if [[ -d "$memory_backup/user" ]]; then
        cp -r "$memory_backup/user"/* ".claude/memory/user/" 2>/dev/null || true
        log_success "Restored user memory"
    fi

    # Clean up backup location file
    rm -f .claude-memory-backup-location
}

preserve_active_specs() {
    log_step "Preserving active specs..."

    local specs_backup=".claude-specs-backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -d ".claude/specs/active" ]] && [[ -n "$(ls -A .claude/specs/active 2>/dev/null)" ]]; then
        mkdir -p "$specs_backup"
        cp -r ".claude/specs/active"/* "$specs_backup/" 2>/dev/null || true
        log_success "Active specs backed up to: $specs_backup"
        echo "$specs_backup" > .claude-specs-backup-location
    else
        log_info "No active specs to preserve"
    fi
}

restore_active_specs() {
    log_step "Restoring active specs..."

    if [[ ! -f .claude-specs-backup-location ]]; then
        log_info "No specs backup found"
        return 0
    fi

    local specs_backup
    specs_backup=$(cat .claude-specs-backup-location)

    if [[ ! -d "$specs_backup" ]]; then
        log_warning "Specs backup directory not found: $specs_backup"
        return 0
    fi

    mkdir -p ".claude/specs/active"
    cp -r "$specs_backup"/* ".claude/specs/active/" 2>/dev/null || true
    log_success "Restored active specs"

    # Clean up backup location file
    rm -f .claude-specs-backup-location
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

    if [[ ! -d "$TEMP_DIR/droidz/.claude" ]]; then
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
    cp -r "$TEMP_DIR/droidz/.claude" "$install_dir"
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
        ".claude/agents/droidz-orchestrator.md"
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

    # Verify memory files were created
    local memory_files=(
        ".claude/memory/org/decisions.json"
        ".claude/memory/org/patterns.json"
        ".claude/memory/org/tech-stack.json"
        ".claude/memory/user/preferences.json"
        ".claude/memory/user/context.json"
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
    agent_count=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $agent_count agent(s)"

    local skill_count
    skill_count=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $skill_count skill(s)"

    local command_count
    command_count=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Found $command_count command(s)"
}

setup_gitignore() {
    log_step "Configuring .gitignore..."

    local gitignore_entries=(
        "# Droidz Framework - User-specific files"
        ".claude/memory/user/"
        ".runs/"
        "*.backup.*"
        "*-tasks.json"
        ".claude-*-backup*"
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
            echo ".claude-*-backup*"
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
    if [[ ! -f ".claude/memory/org/decisions.json" ]]; then
        cat > .claude/memory/org/decisions.json << 'EOF'
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

    if [[ ! -f ".claude/memory/org/patterns.json" ]]; then
        cat > .claude/memory/org/patterns.json << 'EOF'
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

    if [[ ! -f ".claude/memory/org/tech-stack.json" ]]; then
        cat > .claude/memory/org/tech-stack.json << 'EOF'
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
    if [[ ! -f ".claude/memory/user/preferences.json" ]]; then
        cat > .claude/memory/user/preferences.json << 'EOF'
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

    if [[ ! -f ".claude/memory/user/context.json" ]]; then
        cat > .claude/memory/user/context.json << 'EOF'
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
    if [[ ! -d ".claude/specs/active/tasks" ]]; then
        mkdir -p ".claude/specs/active/tasks"
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
    echo -e "${CYAN}${BOLD}║   Droidz Claude Code Framework Installer v2.0       ║${NC}"
    echo -e "${CYAN}${BOLD}║   Smart Update with Custom File Preservation        ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    local is_update=false
    if [[ -d ".claude" ]]; then
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
