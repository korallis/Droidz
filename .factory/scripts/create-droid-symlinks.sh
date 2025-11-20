#!/bin/bash
#
# Create Droid Symlink Workaround
# Works around Factory.ai CLI bug that looks for .json instead of .md
#
# This creates symbolic links: droidz-codegen.json -> droidz-codegen.md
# When Factory.ai looks for .json, it gets .md content instead
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Creating symlink workaround for Factory.ai droid loading bug...${NC}"
echo ""

# Check if we're in a project with .factory/droids
if [ ! -d ".factory/droids" ]; then
    echo -e "${RED}Error: .factory/droids directory not found${NC}"
    echo "Run this from your project root"
    exit 1
fi

cd .factory/droids

# Count .md files
md_count=$(ls -1 *.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$md_count" -eq 0 ]; then
    echo -e "${RED}Error: No .md droid files found${NC}"
    exit 1
fi

echo -e "${BLUE}Found $md_count droid(s) to create symlinks for:${NC}"
echo ""

# Create symlinks
created=0
for md_file in *.md; do
    base="${md_file%.md}"
    json_file="${base}.json"
    
    # Check if .json already exists
    if [ -e "$json_file" ]; then
        if [ -L "$json_file" ]; then
            echo -e "  ${YELLOW}→${NC} $json_file (symlink already exists)"
        else
            echo -e "  ${RED}✗${NC} $json_file (real file exists, skipping)"
        fi
    else
        # Create symlink
        ln -s "$md_file" "$json_file"
        echo -e "  ${GREEN}✓${NC} Created: $json_file → $md_file"
        ((created++))
    fi
done

echo ""
echo -e "${GREEN}Symlink workaround complete!${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  • Created: $created symlink(s)"
echo "  • Total droids: $md_count"
echo ""
echo -e "${YELLOW}What this does:${NC}"
echo "  When Factory.ai looks for droidz-codegen.json,"
echo "  it will read droidz-codegen.md instead."
echo ""
echo -e "${YELLOW}To remove symlinks later:${NC}"
echo "  cd .factory/droids && rm *.json"
echo ""
echo -e "${YELLOW}To add to .gitignore:${NC}"
echo "  echo '*.json' >> .factory/droids/.gitignore"
echo ""
