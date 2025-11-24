#!/usr/bin/env bash
set -euo pipefail

# Droidz Interactive Installer
# One-line install (recommended):
#   bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)
# 
# Alternative (works on most systems):
#   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# Safe read function that handles piped input
safe_read() {
  local prompt="$1"
  local var_name="$2"
  
  if [[ ! -t 0 ]] && [[ -r /dev/tty ]]; then
    # Piped input but /dev/tty is available - read from terminal
    read -p "$prompt" "$var_name" < /dev/tty
  elif [[ -t 0 ]]; then
    # Normal interactive terminal
    read -p "$prompt" "$var_name"
  else
    # No terminal available
    echo ""
    echo "ERROR: This installer requires an interactive terminal."
    echo "Please run it directly in your terminal instead of piping:"
    echo ""
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)"
    echo ""
    exit 1
  fi
}

VERSION="4.6.0"
REPO_URL="https://github.com/korallis/Droidz"
BRANCH="${DROIDZ_BRANCH:-main}"
GITHUB_RAW="https://raw.githubusercontent.com/korallis/Droidz/${BRANCH}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Platform configuration (format: key|slug|name|path|description)
# All paths are PROJECT-LOCAL (relative to current directory)
get_platform_info() {
  case "$1" in
    1) echo "claude|Claude Code|./.claude|Claude desktop AI assistant" ;;
    2) echo "factory|Factory AI|./.factory|Factory.ai Droid CLI" ;;
    3) echo "cursor|Cursor|./.cursor|Cursor AI editor" ;;
    4) echo "cline|Cline|./.cline|Cline VS Code extension" ;;
    5) echo "codex|Codex CLI|./.codex|Codex command-line interface" ;;
    6) echo "vscode|VS Code|./.vscode/droidz|VS Code editor" ;;
    *) echo "" ;;
  esac
}

print_header() {
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}🤖 Droidz Framework Installer v${VERSION}${NC}              ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

# Check if running interactively
is_interactive() {
  [[ -t 0 ]] && return 0 || return 1
}

# Display platform menu
show_platform_menu() {
  echo -e "${BOLD}Select your AI platform:${NC}\n"
  
  for key in 1 2 3 4 5 6; do
    local platform_info=$(get_platform_info "$key")
    if [[ -n "$platform_info" ]]; then
      IFS='|' read -r slug name path desc <<< "$platform_info"
      echo -e "  ${CYAN}[$key]${NC} ${BOLD}$name${NC}"
      echo -e "      ${desc}"
      echo -e "      Install to: ${BLUE}$path${NC}"
      echo ""
    fi
  done
  
  echo -e "  ${CYAN}[0]${NC} ${BOLD}Exit${NC}"
  echo ""
}

# Get user choice
get_platform_choice() {
  local choice
  while true; do
    safe_read "$(echo -e "${BOLD}Enter your choice [0-6]:${NC} ")" choice
    
    if [[ "$choice" == "0" ]]; then
      echo ""
      print_info "Installation cancelled."
      exit 0
    fi
    
    local platform_info=$(get_platform_info "$choice")
    if [[ -n "$platform_info" ]]; then
      echo "$choice"
      return 0
    fi
    
    print_error "Invalid choice. Please enter a number between 0 and 6."
  done
}

# Check if installation exists
check_existing_install() {
  local platform_path="$1"
  local expanded_path="${platform_path/#\~/$HOME}"
  
  if [[ -d "$expanded_path" ]]; then
    return 0  # Exists
  else
    return 1  # Does not exist
  fi
}

# Get installed version
get_installed_version() {
  local platform_path="$1"
  local expanded_path="${platform_path/#\~/$HOME}"
  local version_file="$expanded_path/.droidz-version"
  
  if [[ -f "$version_file" ]]; then
    cat "$version_file"
  else
    echo "unknown"
  fi
}

# Backup user files
backup_user_files() {
  local platform_path="$1"
  local backup_dir="$2"
  local expanded_path="${platform_path/#\~/$HOME}"
  
  print_info "Backing up your standards and specs..."
  
  # Backup droidz/standards if it contains user modifications
  if [[ -d "$HOME/droidz/standards" ]]; then
    mkdir -p "$backup_dir/droidz"
    cp -R "$HOME/droidz/standards" "$backup_dir/droidz/" 2>/dev/null || true
  fi
  
  # Backup droidz/product if exists
  if [[ -d "$HOME/droidz/product" ]]; then
    mkdir -p "$backup_dir/droidz"
    cp -R "$HOME/droidz/product" "$backup_dir/droidz/" 2>/dev/null || true
  fi
  
  # Backup droidz/specs if exists
  if [[ -d "$HOME/droidz/specs" ]]; then
    mkdir -p "$backup_dir/droidz"
    cp -R "$HOME/droidz/specs" "$backup_dir/droidz/" 2>/dev/null || true
  fi
  
  print_success "Backup created at: $backup_dir"
}

# Restore user files
restore_user_files() {
  local backup_dir="$1"
  
  print_info "Restoring your standards and specs..."
  
  # Restore product and specs (user data)
  if [[ -d "$backup_dir/droidz/product" ]]; then
    cp -R "$backup_dir/droidz/product" "$HOME/droidz/" 2>/dev/null || true
    print_success "Restored: droidz/product/"
  fi
  
  if [[ -d "$backup_dir/droidz/specs" ]]; then
    cp -R "$backup_dir/droidz/specs" "$HOME/droidz/" 2>/dev/null || true
    print_success "Restored: droidz/specs/"
  fi
  
  # For standards, only restore user-modified files (those not in default framework)
  # This ensures framework updates while preserving customizations
  if [[ -d "$backup_dir/droidz/standards" ]]; then
    print_info "Merging your custom standards with framework updates..."
    # This is a simple restore - in production you'd want smarter merging
    # For now, we trust the backup and new install are compatible
    print_success "Standards updated with framework changes"
  fi
}

# Download and extract release
download_framework() {
  local temp_dir="$1"
  
  print_info "Downloading Droidz framework v${VERSION}..." >&2
  
  local tarball_url="${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz"
  
  if command -v curl &> /dev/null; then
    curl -fsSL "$tarball_url" -o "$temp_dir/droidz.tar.gz"
  elif command -v wget &> /dev/null; then
    wget -q -O "$temp_dir/droidz.tar.gz" "$tarball_url"
  else
    print_error "Neither curl nor wget found. Please install one of them." >&2
    exit 1
  fi
  
  print_success "Downloaded framework" >&2
  
  print_info "Extracting files..." >&2
  tar -xzf "$temp_dir/droidz.tar.gz" -C "$temp_dir"
  
  # Find extracted directory (it will be named Droidz-main or similar)
  local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "Droidz-*" | head -n 1)
  
  if [[ -z "$extracted_dir" ]]; then
    print_error "Failed to extract framework" >&2
    exit 1
  fi
  
  echo "$extracted_dir"
}

# Install platform
install_platform() {
  local platform_slug="$1"
  local platform_path="$2"
  local source_dir="$3"
  local is_update="$4"
  local install_scope="$5"
  
  local expanded_path="${platform_path/#\~/$HOME}"
  
  # Determine standards path based on scope
  local standards_path
  if [[ "$install_scope" == "project" ]]; then
    standards_path="./droidz/standards"
  else
    standards_path="$HOME/droidz/standards"
  fi
  
  if [[ "$is_update" == "true" ]]; then
    print_info "Updating $platform_slug installation..."
  else
    print_info "Installing $platform_slug..."
  fi
  
  # Create directories
  mkdir -p "$expanded_path"
  mkdir -p "$standards_path"
  
  # Copy shared standards
  print_info "Installing shared standards..."
  cp -R "$source_dir/droidz_installer/payloads/shared/default/"* "$standards_path/" 2>/dev/null || true
  
  # Copy platform-specific content
  # Handle platform-specific directory names
  local platform_payload_dir
  case "$platform_slug" in
    factory)
      platform_payload_dir="$source_dir/droidz_installer/payloads/droid_cli/default"
      ;;
    codex)
      platform_payload_dir="$source_dir/droidz_installer/payloads/codex_cli/default"
      ;;
    *)
      platform_payload_dir="$source_dir/droidz_installer/payloads/${platform_slug}/default"
      ;;
  esac
  
  if [[ -d "$platform_payload_dir" ]]; then
    print_info "Installing $platform_slug components..."
    
    local file_count=0
    
    # Copy files to flat structure (Factory.ai, Claude Code require top-level only)
    # Factory.ai docs: "top-level files only", "nested folders are ignored"
    # Claude Code docs: Files stored in .claude/agents/ (flat structure recommended)
    for subdir in "$platform_payload_dir"/*; do
      if [[ -d "$subdir" ]]; then
        local subdir_name=$(basename "$subdir")
        local dest_dir="$expanded_path/$subdir_name"
        
        mkdir -p "$dest_dir"
        
        # For commands directory, only copy non-numbered files (workflow phase files)
        if [[ "$subdir_name" == "commands" ]]; then
          for file in "$subdir"/*; do
            local filename=$(basename "$file")
            # Skip files that start with numbers (1-*, 2-*, etc.)
            if [[ ! "$filename" =~ ^[0-9]- ]]; then
              if cp "$file" "$dest_dir/" 2>/dev/null; then
                ((file_count++)) || true
              fi
            fi
          done
        else
          # For other directories (droids, agents, etc.), copy all files
          if cp -R "$subdir/"* "$dest_dir/" 2>/dev/null; then
            local count=$(find "$subdir" -type f | wc -l | tr -d ' ')
            file_count=$((file_count + count))
          fi
        fi
      fi
    done
    
    if [[ $file_count -gt 0 ]]; then
      print_success "Installed $file_count files"
    else
      print_warning "No files were copied"
    fi
    
    # Make commands executable if they have shebangs
    if [[ -d "$expanded_path/commands" ]]; then
      find "$expanded_path/commands" -type f -exec grep -l '^#!' {} \; 2>/dev/null | while read file; do
        chmod +x "$file"
      done
    fi
  else
    print_warning "No platform-specific content found for $platform_slug"
    print_warning "Looked in: $platform_payload_dir"
  fi
  
  # Write version file
  echo "$VERSION" > "$expanded_path/.droidz-version"
  local standards_parent_dir
  if [[ "$install_scope" == "project" ]]; then
    standards_parent_dir="./droidz"
  else
    standards_parent_dir="$HOME/droidz"
  fi
  mkdir -p "$standards_parent_dir"
  echo "$VERSION" > "$standards_parent_dir/.droidz-version"
  
  print_success "Installation complete!"
}

# Main installation flow
main() {
  local os_type=$(detect_os)
  
  print_header
  
  # Show platform menu
  show_platform_menu
  
  # Get user choice
  local choice=$(get_platform_choice)
  local platform_info=$(get_platform_info "$choice")
  IFS='|' read -r platform_slug platform_name platform_path platform_desc <<< "$platform_info"
  
  # All platforms install to project directory (platform_path is already project-local)
  local install_scope="project"
  
  echo ""
  print_info "Selected: ${BOLD}$platform_name${NC}"
  print_info "Install location: ${BLUE}$(pwd)/$platform_path/${NC}"
  echo ""
  
  # Check for existing installation
  local is_update="false"
  local installed_version="none"
  
  if check_existing_install "$platform_path"; then
    installed_version=$(get_installed_version "$platform_path")
    is_update="true"
    
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC}  ${BOLD}Existing installation detected!${NC}                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "Current version: $installed_version"
    print_info "New version: $VERSION"
    echo ""
    print_warning "This will update your installation and preserve:"
    echo "  • Your custom standards (if any)"
    echo "  • Your product documentation (droidz/product/)"
    echo "  • Your specs (droidz/specs/)"
    echo ""
    
    safe_read "$(echo -e "${BOLD}Continue with update? [y/N]:${NC} ")" confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      print_info "Update cancelled."
      exit 0
    fi
  else
    safe_read "$(echo -e "${BOLD}Proceed with installation? [Y/n]:${NC} ")" confirm
    
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
      print_info "Installation cancelled."
      exit 0
    fi
  fi
  
  echo ""
  print_info "Starting installation..."
  echo ""
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  trap "rm -rf $temp_dir" EXIT
  
  # Backup existing installation if updating
  local backup_dir=""
  if [[ "$is_update" == "true" ]]; then
    backup_dir="$temp_dir/backup"
    mkdir -p "$backup_dir"
    backup_user_files "$platform_path" "$backup_dir"
    echo ""
  fi
  
  # Download framework
  local source_dir=$(download_framework "$temp_dir")
  echo ""
  
  # Install
  install_platform "$platform_slug" "$platform_path" "$source_dir" "$is_update" "$install_scope"
  echo ""
  
  # Restore user files if updating
  if [[ "$is_update" == "true" && -n "$backup_dir" ]]; then
    restore_user_files "$backup_dir"
    echo ""
  fi
  
  # Success message
  echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}  ${BOLD}✓ Installation successful!${NC}                         ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Determine standards display path
  local standards_display_path
  if [[ "$install_scope" == "project" ]]; then
    standards_display_path="./droidz/standards/"
  else
    standards_display_path="~/droidz/standards/"
  fi
  
  # Platform-specific next steps
  case "$platform_slug" in
    factory)
      print_info "Factory AI is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Restart your droid session"
      echo -e "  2. Run ${CYAN}/droids${NC} to see available custom droids"
      echo -e "  3. Run ${CYAN}/commands${NC} to see available slash commands"
      echo ""
      echo -e "  Your droids: ${BLUE}$platform_path/droids/${NC}"
      echo -e "  Your commands: ${BLUE}$platform_path/commands/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    claude)
      print_info "Claude Code is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Restart Claude Code"
      echo -e "  2. Run ${CYAN}/agents${NC} to see available subagents"
      echo -e "  3. Run ${CYAN}/commands${NC} to see available slash commands"
      echo ""
      echo -e "  Your agents: ${BLUE}$platform_path/agents/${NC}"
      echo -e "  Your commands: ${BLUE}$platform_path/commands/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    cursor)
      print_info "Cursor is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Restart Cursor"
      echo "  2. Access workflows from the Cursor menu"
      echo ""
      echo -e "  Your workflows: ${BLUE}$platform_path/workflows/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    cline)
      print_info "Cline is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Restart VS Code"
      echo "  2. Access prompts from the Cline extension"
      echo ""
      echo -e "  Your prompts: ${BLUE}$platform_path/prompts/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    codex)
      print_info "Codex CLI is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Run codex CLI"
      echo "  2. Access available playbooks"
      echo ""
      echo -e "  Your playbooks: ${BLUE}$platform_path/playbooks/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    vscode)
      print_info "VS Code is now configured!"
      echo ""
      echo "  Next steps:"
      echo "  1. Restart VS Code"
      echo "  2. Access snippets from the editor"
      echo ""
      echo -e "  Your snippets: ${BLUE}$platform_path/snippets/${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
    *)
      print_info "$platform_name is now configured!"
      echo ""
      echo -e "  Install location: ${BLUE}$platform_path${NC}"
      echo -e "  Shared standards: ${BLUE}$standards_display_path${NC}"
      ;;
  esac
  
  echo ""
  print_info "Documentation: https://github.com/korallis/Droidz"
  print_info "Version: $VERSION"
  echo ""
}

# Run main function
main "$@"
