#!/bin/bash
#
# Droidz Diagnostic Script
# Diagnoses why Factory.ai can't find droids during parallel execution
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   Droidz Diagnostic Tool                            ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a project with .factory directory
if [[ ! -d ".factory" ]]; then
    echo -e "${RED}✗${NC} .factory directory not found"
    echo -e "${YELLOW}  Run this from your project root where .factory/ exists${NC}"
    exit 1
fi

echo -e "${BLUE}Checking Factory.ai custom droids setup...${NC}"
echo ""

# 1. Check if droids directory exists
echo -e "${BOLD}1. Droids Directory:${NC}"
if [[ -d ".factory/droids" ]]; then
    echo -e "   ${GREEN}✓${NC} .factory/droids/ exists"
    
    # Count .md files
    md_count=$(find .factory/droids -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
    json_count=$(find .factory/droids -maxdepth 1 -name "*.json" | wc -l | tr -d ' ')
    
    echo -e "   ${BLUE}→${NC} Found ${md_count} .md droid(s)"
    echo -e "   ${BLUE}→${NC} Found ${json_count} .json droid(s)"
    
    if [[ $md_count -gt 0 ]]; then
        echo ""
        echo -e "   ${CYAN}Installed droids (.md):${NC}"
        find .factory/droids -maxdepth 1 -name "*.md" -exec basename {} \; | sed 's/^/     • /'
    fi
    
    if [[ $json_count -gt 0 ]]; then
        echo ""
        echo -e "   ${YELLOW}⚠ Found .json droids (Factory.ai expects .md):${NC}"
        find .factory/droids -maxdepth 1 -name "*.json" -exec basename {} \; | sed 's/^/     • /'
    fi
else
    echo -e "   ${RED}✗${NC} .factory/droids/ does NOT exist"
    echo -e "   ${YELLOW}→ Droids need to be in: .factory/droids/${NC}"
fi

echo ""

# 2. Check Factory.ai CLI version
echo -e "${BOLD}2. Factory.ai CLI:${NC}"
if command -v droid &>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Factory.ai CLI installed"
    
    # Try to get version
    if droid --version &>/dev/null; then
        version=$(droid --version 2>&1 || echo "unknown")
        echo -e "   ${BLUE}→${NC} Version: ${version}"
    else
        echo -e "   ${YELLOW}⚠${NC} Could not determine version"
    fi
else
    echo -e "   ${RED}✗${NC} Factory.ai CLI (droid) not found"
    echo -e "   ${YELLOW}→ Install: npm install -g @factory-ai/cli${NC}"
fi

echo ""

# 3. Check if custom droids are enabled
echo -e "${BOLD}3. Custom Droids Setting:${NC}"
if [[ -f "$HOME/.factory/settings.json" ]]; then
    if grep -q '"enableCustomDroids"' "$HOME/.factory/settings.json" 2>/dev/null; then
        if grep -q '"enableCustomDroids".*:.*true' "$HOME/.factory/settings.json" 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Custom droids are ENABLED"
        else
            echo -e "   ${RED}✗${NC} Custom droids are DISABLED"
            echo -e "   ${YELLOW}→ Enable in Factory.ai: /settings → Custom Droids → ON${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Setting not found in ~/.factory/settings.json"
        echo -e "   ${YELLOW}→ Enable in Factory.ai: /settings → Custom Droids → ON${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} ~/.factory/settings.json not found"
    echo -e "   ${YELLOW}→ Factory.ai settings file missing${NC}"
fi

echo ""

# 4. Check droid YAML frontmatter format
echo -e "${BOLD}4. Droid Format Validation:${NC}"
if [[ -d ".factory/droids" ]]; then
    invalid_droids=()
    
    while IFS= read -r droid_file; do
        if [[ -f "$droid_file" ]]; then
            # Check if file starts with ---
            if ! head -1 "$droid_file" | grep -q '^---$'; then
                invalid_droids+=("$droid_file")
            fi
        fi
    done < <(find .factory/droids -maxdepth 1 -name "*.md")
    
    if [[ ${#invalid_droids[@]} -eq 0 ]]; then
        echo -e "   ${GREEN}✓${NC} All .md droids have valid YAML frontmatter"
    else
        echo -e "   ${RED}✗${NC} Invalid droid format detected:"
        for invalid in "${invalid_droids[@]}"; do
            echo -e "     ${YELLOW}→${NC} $(basename "$invalid")"
        done
        echo ""
        echo -e "   ${CYAN}Expected format:${NC}"
        echo -e "   ${CYAN}---${NC}"
        echo -e "   ${CYAN}name: droidz-codegen${NC}"
        echo -e "   ${CYAN}description: ...${NC}"
        echo -e "   ${CYAN}model: inherit${NC}"
        echo -e "   ${CYAN}tools: [\"Read\", \"Edit\"]${NC}"
        echo -e "   ${CYAN}---${NC}"
        echo ""
        echo -e "   ${CYAN}Your droid prompt goes here...${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} No droids directory to validate"
fi

echo ""

# 5. Known issue detection
echo -e "${BOLD}5. Known Issues:${NC}"
if [[ -d ".factory/droids" ]]; then
    md_count=$(find .factory/droids -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
    
    if [[ $md_count -gt 0 ]]; then
        echo -e "   ${YELLOW}⚠ KNOWN BUG DETECTED:${NC}"
        echo ""
        echo -e "   ${YELLOW}Factory.ai is looking for .json files but droids are .md${NC}"
        echo -e "   ${YELLOW}This is a Factory.ai CLI bug/version mismatch.${NC}"
        echo ""
        echo -e "   ${CYAN}Temporary Workaround:${NC}"
        echo -e "   1. Update Factory.ai CLI:"
        echo -e "      ${CYAN}npm install -g @factory-ai/cli@latest${NC}"
        echo ""
        echo -e "   2. Restart Factory.ai:"
        echo -e "      ${CYAN}Exit (Ctrl+C) then run: droid${NC}"
        echo ""
        echo -e "   3. Report to Factory.ai:"
        echo -e "      ${CYAN}https://github.com/factory-ai/factory-cli/issues${NC}"
        echo -e "      Mention: \"Custom droids looking for .json instead of .md\""
    else
        echo -e "   ${GREEN}✓${NC} No known issues detected"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} Cannot check (no droids directory)"
fi

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   Diagnostic Complete                                ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Summary
echo -e "${BOLD}Summary:${NC}"
echo ""
if [[ -d ".factory/droids" ]]; then
    md_count=$(find .factory/droids -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
    
    if [[ $md_count -gt 0 ]]; then
        echo -e "${YELLOW}Your droids are installed correctly as .md files.${NC}"
        echo -e "${YELLOW}The issue is Factory.ai CLI looking for .json files.${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo -e "1. Update Factory.ai CLI: ${BOLD}npm install -g @factory-ai/cli@latest${NC}"
        echo -e "2. Restart Factory.ai"
        echo -e "3. Try running orchestrator again"
        echo ""
        echo -e "If still broken after update, report to Factory.ai team."
    else
        echo -e "${RED}No droids found in .factory/droids/${NC}"
        echo -e "Run Droidz installer to install droids."
    fi
else
    echo -e "${RED}.factory/droids/ directory not found${NC}"
    echo -e "Run Droidz installer first."
fi

echo ""
